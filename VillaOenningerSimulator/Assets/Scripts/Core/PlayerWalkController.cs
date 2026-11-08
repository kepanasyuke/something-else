using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class PlayerWalkController : MonoBehaviour
{
    [Header("Movement")]
    public float walkSpeed = 4.2f;
    public float runSpeed = 7.0f;
    public float jumpHeight = 1.1f;
    public float gravity = -9.81f;

    [Header("Look")]
    public float mouseSensitivity = 2.2f;
    public float minPitch = -85f;
    public float maxPitch = 85f;

    [Header("State")]
    public bool controlEnabled = false;
    public Transform cameraPivot;

    private CharacterController controller;
    private float pitch = 0f;
    private Vector3 verticalVelocity;

    private void Awake()
    {
        controller = GetComponent<CharacterController>();
        if (cameraPivot == null && Camera.main != null)
            cameraPivot = Camera.main.transform;
    }

    private void Start()
    {
        EnableControl(false);
    }

    public void EnableControl(bool value)
    {
        controlEnabled = value;

        if (controller != null)
            controller.enabled = value;

        Cursor.lockState = value ? CursorLockMode.Locked : CursorLockMode.None;
        Cursor.visible = !value;
    }

    private void Update()
    {
        if (!controlEnabled) return;

        Look();
        Move();
    }

    private void Look()
    {
        float mx = Input.GetAxis("Mouse X") * mouseSensitivity;
        float my = Input.GetAxis("Mouse Y") * mouseSensitivity;

        transform.Rotate(Vector3.up, mx, Space.Self);

        pitch = Mathf.Clamp(pitch - my, minPitch, maxPitch);
        if (cameraPivot != null)
            cameraPivot.localRotation = Quaternion.Euler(pitch, 0f, 0f);
    }

    private void Move()
    {
        float h = Input.GetAxis("Horizontal");
        float v = Input.GetAxis("Vertical");

        Vector3 direction = transform.right * h + transform.forward * v;
        if (direction.sqrMagnitude > 1f)
            direction.Normalize();

        float speed = Input.GetKey(KeyCode.LeftShift) ? runSpeed : walkSpeed;

        if (controller.isGrounded && verticalVelocity.y < 0f)
            verticalVelocity.y = -2f;

        if (controller.isGrounded && Input.GetButtonDown("Jump"))
            verticalVelocity.y = Mathf.Sqrt(jumpHeight * -2f * gravity);

        verticalVelocity.y += gravity * Time.deltaTime;

        Vector3 motion = direction * speed + verticalVelocity;
        controller.Move(motion * Time.deltaTime);
    }
}
