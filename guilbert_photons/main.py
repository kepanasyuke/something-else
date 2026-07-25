import asyncio
import io
import base64
import logging
import numpy as np
import matplotlib
# Инициализируем безэкранный бэкенд для работы matplotlib в потоках FastAPI
matplotlib.use('Agg')
import matplotlib.pyplot as plt

from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, Field
from typing import List, Optional

# --- СХЕМЫ ДАННЫХ КОНТРАКТА ---
class DocumentSchema(BaseModel):
    id: int
    rubrics: List[str] = Field(default_factory=list)
    text: str
    created_date: Optional[str] = None

class SearchRequest(BaseModel):
    query: str

class SearchResponse(BaseModel):
    results: List[DocumentSchema]

# Новая Pydantic-модель для реактивного управления графиками
class PlotRequest(BaseModel):
    frequency: float  # Сюда прилетает значение ω со слайдера фронтенда

class PlotResponse(BaseModel):
    packet_plot: str  # Картинка 1 в формате Base64
    area_plot: str    # Картинка 2 в формате Base64
    scale_plot: str   # Картинка 3 в формате Base64

# Настройка Enterprise-логирования
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)
logger = logging.getLogger("QuantumEngine")

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("--- [Инициализация] Математический движок Гильбертовых полей запущен ---")
    yield
    logger.info("--- [Остановка] Завершение работы вычислительных ядер ---")

app = FastAPI(title="Search & Quantum Field Service", version="3.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- 🔬 МАТЕМАТИЧЕСКОЕ ЯДРО (ОБСЧЕТ И ОТРИСОВКА ЧЕРТЕЖЕЙ) ---
def compute_and_render_plots(omega: float) -> dict:
    """
    Чистая CPU-функция для генерации графиков. 
    Выполняется в отдельном системном потоке, чтобы не блокировать FastAPI.
    """
    plots_base64 = {}
    
    # Общие стили строгого минимализма Гейзенберга
    plt.style.use('dark_background')
    bg_color = '#0b0f17'
    
    # 1. График: Волновой пакет Шрёдингера
    fig, ax = plt.subplots(figsize=(5, 3.5), facecolor=bg_color)
    ax.set_facecolor(bg_color)
    x = np.linspace(-5, 5, 400)
    sigma = 1.0
    k0 = omega * 2.0
    psi_real = np.exp(-x**2 / (4 * sigma**2)) * np.cos(k0 * x)
    probability_density = np.exp(-x**2 / (2 * sigma**2))
    
    ax.plot(x, psi_real, color='#3b82f6', linewidth=1.8, label='Real Ψ(x)')
    ax.plot(x, probability_density, color='#f59e0b', linewidth=1.2, linestyle='--', label='|Ψ|² Density')
    ax.set_title(r"$\Psi(x) = e^{-\frac{x^2}{4\sigma^2}} \cdot e^{ik_0 x}$", fontsize=11, color='#cbd5e1')
    ax.set_ylim(-1.2, 1.2)
    ax.axis('off')
    
    buf = io.BytesIO()
    plt.savefig(buf, format='png', dpi=120, bbox_inches='tight', facecolor=bg_color)
    buf.seek(0)
    plots_base64['packet'] = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)

    # 2. График: Дискретные кванты площади (Спиновая сеть)
    fig, ax = plt.subplots(figsize=(5, 3.5), facecolor=bg_color)
    ax.set_facecolor(bg_color)
    # Генерируем псевдослучайные узлы сети, зависящие от частоты ω
    np.random.seed(int(omega * 10))
    num_nodes = int(omega * 4) + 4
    nodes_x = np.random.uniform(-2, 2, num_nodes)
    nodes_y = np.random.uniform(-2, 2, num_nodes)
    
    # Рисуем квантовые нити связей
    for i in range(num_nodes):
        for j in range(i+1, num_nodes):
            if np.hypot(nodes_x[i]-nodes_x[j], nodes_y[i]-nodes_y[j]) < 1.8:
                ax.plot([nodes_x[i], nodes_x[j]], [nodes_y[i], nodes_y[j]], color='#10b981', stroke_width=0.5, alpha=0.3)
                
    ax.scatter(nodes_x, nodes_y, color='#14b8a6', s=45, zorder=5, edgecolors='#ffffff', linewidths=0.5)
    ax.set_title(r"$A = 8\pi\gamma \ell_P^2 \sum \sqrt{j_i(j_i+1)}$", fontsize=11, color='#cbd5e1')
    ax.axis('off')
    
    buf = io.BytesIO()
    plt.savefig(buf, format='png', dpi=120, bbox_inches='tight', facecolor=bg_color)
    buf.seek(0)
    plots_base64['area'] = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)

    # 3. График: Масштаб поля (Ренормализация)
    fig, ax = plt.subplots(figsize=(5, 3.5), facecolor=bg_color)
    ax.set_facecolor(bg_color)
    mu = np.linspace(0.1, 10, 200)
    # Бегущая константа связи, изменяющая траекторию от ω
    alpha = 1.0 / (0.5 * omega * np.log(mu + 1) + 0.2)
    
    ax.plot(mu, alpha, color='#8b5cf6', linewidth=2)
    ax.axvline(x=7.5, color='#ef4444', linestyle=':', linewidth=1.2, label='Planck Scale')
    ax.set_title(r"$\frac{d\alpha}{d\ln\mu} = \beta(\alpha)$ (Field Scale)", fontsize=11, color='#cbd5e1')
    ax.axis('off')
    
    buf = io.BytesIO()
    plt.savefig(buf, format='png', dpi=120, bbox_inches='tight', facecolor=bg_color)
    buf.seek(0)
    plots_base64['scale'] = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)

    return plots_base64

# --- 🚀 REST ЭНДПОИНТЫ ---

@app.get("/", response_class=FileResponse)
async def root():
    return FileResponse("static/index.html"

@app.post("/generate-plots", response_model=PlotResponse)
async def generate_quantum_plots(request: PlotRequest):
    logger.info("Запрос на рендеринг квантового поля. Координата частоты ω = %s", request.frequency)
    try:
        # [Архитектурный паттерн]: выносим тяжелую графику Matplotlib в thread pool, 
        # защищая Event Loop сервера от зависания
        loop = asyncio.get_running_loop()
        encoded_plots = await loop.run_in_executor(None, compute_and_render_plots, request.frequency)
        
        return PlotResponse(
            packet_plot=encoded_plots['packet'],
            area_plot=encoded_plots['area'],
            scale_plot=encoded_plots['scale']
        )
    except Exception as e:
        logger.error("Критический сбой математического ядра: %s", e)
        raise HTTPException(status_code=500, detail="Ошибка вычисления топологии поля")

@app.post("/search", response_model=SearchResponse)
async def search(request: SearchRequest):
    logger.info("Полнотекстовый поиск Elasticsearch. Запрос: '%s'", request.query)
    await asyncio.sleep(4.5) # Сетевое ожидание под звуковой сценарий
    
    mock_results = [
        DocumentSchema(id=1024, rubrics=["политика", "финансы"], text=f"Документ по запросу '{request.query}'. Вектор состояния стабилен в гильбертовом поле."),
        DocumentSchema(id=2048, rubrics=["наука", "кванты"], text=f"Архивная выписка 1С. Квантование волновой функции зафиксировано успешно.")
    ]
    return SearchResponse(results=mock_results)

@app.delete("/documents/{doc_id}")
async def delete_doc(doc_id: int):
    return {"status": "deleted"}

@app.get("/health", include_in_schema=False)
async def health_check():
    return {"status": "ok"}

@app.mount("/static", StaticFiles(directory="static"), name="static")

#@app.get("/", response_class=FileResponse)
#async def root():
#    return FileResponse("static/index.html")



