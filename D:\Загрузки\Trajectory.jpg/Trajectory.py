import numpy as np
from scipy.interpolate import interp1d

# ------------------- КОНСТАНТЫ РЕАЛЬНОСТИ ----------------------
KEGOL_SECOND = 5.39e-44   # планковское время (кегольсекунда)
ROND_STEPS = 5            # число шагов в цикле перехода
MIN_STATES = 16           # минимальное число состояний (при низкой когерентности)
MAX_STATES = 24           # максимальное число состояний (при высокой когерентности)

# ---------------------------------------------------------------
#  1. ТРАЕКТОРИЯ ДВИЖЕНИЯ ПЛАСТИНЫ
# ---------------------------------------------------------------
class Trajectory:
    """
    Параметрическая траектория: линейная, окружность, спираль, сплайн.
    Возвращает положение и ориентацию в момент времени t.
    """
    def __init__(self, kind='linear', params=None):
        self.kind = kind
        self.params = params or {}
        self._init_trajectory()

    def _init_trajectory(self):
        if self.kind == 'linear':
            self.start = np.array(self.params.get('start', [0,0,0]))
            self.end = np.array(self.params.get('end', [1,0,0]))
            self.speed = self.params.get('speed', 0.1)
            self.direction = self.end - self.start
            self.length = np.linalg.norm(self.direction) + 1e-12
            self.direction = self.direction / self.length
        elif self.kind == 'circular':
            self.center = np.array(self.params.get('center', [0,0,0]))
            self.radius = self.params.get('radius', 1.0)
            self.omega = self.params.get('angular_velocity', 1.0)
            self.axis = np.array(self.params.get('axis', [0,0,1]))
            self.axis = self.axis / np.linalg.norm(self.axis)
            self.initial_angle = self.params.get('initial_angle', 0.0)
        elif self.kind == 'helix':
            self.center = np.array(self.params.get('center', [0,0,0]))
            self.radius = self.params.get('radius', 1.0)
            self.pitch = self.params.get('pitch', 0.5)
            self.omega = self.params.get('angular_velocity', 1.0)
            self.axis = np.array(self.params.get('axis', [0,0,1]))
            self.axis = self.axis / np.linalg.norm(self.axis)
        elif self.kind == 'spline':
            points = np.array(self.params.get('points', [[0,0,0],[1,1,0],[2,0,0]]))
            times = np.array(self.params.get('times', [0,1,2]))
            self.spline_x = interp1d(times, points[:,0], kind='cubic', fill_value='extrapolate')
            self.spline_y = interp1d(times, points[:,1], kind='cubic', fill_value='extrapolate')
            self.spline_z = interp1d(times, points[:,2], kind='cubic', fill_value='extrapolate')
        else:
            raise ValueError(f"Неизвестный тип траектории: {self.kind}")

    def get_orientation(self, t):
        """Возвращает вектор нормали к пластине (касательная к траектории)."""
        dt = 1e-6
        p1 = self.get_position(t)
        p2 = self.get_position(t+dt)
        tangent = p2 - p1
        if np.linalg.norm(tangent) > 1e-12:
            return tangent / np.linalg.norm(tangent)
        return np.array([0,0,1])  

# ---------------------------------------------------------------
#  2. ПЛАСТИНА С БУЛЕВЫМ УПРАВЛЕНИЕМ
# ---------------------------------------------------------------
class Plate:
    """
    Пластина, которая движется по траектории, вибрирует,
    генерирует звук, свет, магнитное и гравитационное поля.
    Её состояние (0 или 1) определяется булевой логической функцией.
    """
    def __init__(self, index, logic_func, trajectory, mass_base=1.0):
        self.index = index                 # номер пластины (0..11)
        self.state = 0                     # текущее булево состояние (0/1)
        self.logic_func = logic_func       # функция, принимающая список состояний всех пластин
        self.trajectory = trajectory
        self.mass_base = mass_base         # базовая масса (умножается на state)
        # Текущие динамические переменные
        self.position = np.zeros(3)
        self.velocity = np.zeros(3)
        self.orientation = np.array([0,0,1])
        self.displacement = 0.0            # смещение при вибрации
        self.vib_velocity = 0.0            # скорость вибрации
        self.phase = 0.0                   # фаза колебаний        
    def update(self, t, dt, all_states):
        """
        Обновить состояние пластины в момент времени t.
        all_states — список состояний всех пластин (для логики).
        """
        # 1. Вычисляем логическое значение (True/False)
        should_move = self.logic_func(all_states)
        amp = 1.0 if should_move else 0.0   # амплитуда вибраций

        # 2. Базовое положение по траектории
        base_pos = self.trajectory.get_position(t)
        self.orientation = self.trajectory.get_orientation(t)

        # 3. Вибрации: частота зависит от индекса и состояния
        if amp > 0.5:
            freq = 440 + self.index * 50
        else:
            freq = 220 + self.index * 25
        omega = 2 * np.pi * freq
        vib_amp = amp * 0.05
        delta = vib_amp * np.sin(omega * t + self.phase)
        self.displacement = delta
        self.vib_velocity = delta * omega * np.cos(omega * t + self.phase)

        # 4. Итоговое положение = траектория + смещение вдоль нормали
        self.position = base_pos + delta * self.orientation

        # 5. Обновляем фазу для следующего шага
        self.phase += omega * dt  
