using UnityEngine;

public class AdvancedSimsCamera : MonoBehaviour
{
    [Header("Tracking Focus")]
    [SerializeField] private Transform focusTarget;

    [Header("Movement Speed & Inertia")]
    [SerializeField] private float keyboardPanSpeed = 25f;
    [SerializeField] private float mouseRotateSpeed = 150f;
    [SerializeField] private float mouseZoomSpeed = 60f;
    [SerializeField] private float interpolationSmoothness = 7.5f;

    [Header("Constraints")]
    [SerializeField] private float minPitchAngle = 10f;
    [SerializeField] private float maxPitchAngle = 80f;
    [SerializeField] private float minZoomDistance = 6f;
    [SerializeField] private float maxZoomDistance = 45f;
    [SerializeField] private float groundHeightLimit = 2f;

    private float currentYawAngle = 45f;
    private float currentPitchAngle = 30f;
    private float targetZoomDistance = 20f;
    private float smoothZoomDistance = 20f;
    private Vector3 calculatedTargetPos;

    private void Awake() => enabled = false;

    private void Start()
    {
        if (focusTarget != null) calculatedTargetPos = focusTarget.position;
    }

    private void LateUpdate()
    {
        if (Input.GetMouseButton(1))
        {
            currentYawAngle += Input.GetAxis("Mouse X") * mouseRotateSpeed * Time.deltaTime;
            currentPitchAngle -= Input.GetAxis("Mouse Y") * mouseRotateSpeed * Time.deltaTime;
            currentPitchAngle = Mathf.Clamp(currentPitchAngle, minPitchAngle, maxPitchAngle);
        }

        float scroll = Input.GetAxis("Mouse ScrollWheel");
        targetZoomDistance = Mathf.Clamp(targetZoomDistance - scroll * mouseZoomSpeed, minZoomDistance, maxZoomDistance);
        smoothZoomDistance = Mathf.Lerp(smoothZoomDistance, targetZoomDistance, Time.deltaTime * interpolationSmoothness);

        float h = Input.GetAxis("Horizontal");
        float v = Input.GetAxis("Vertical");
        if (h != 0 || v != 0)
        {
            Vector3 forward = transform.forward;
            forward.y = 0;
            forward.Normalize();
            Vector3 right = transform.right;
            Vector3 move = (forward * v + right * h).normalized;
            calculatedTargetPos += move * keyboardPanSpeed * Time.deltaTime;
        }

        Quaternion targetRot = Quaternion.Euler(currentPitchAngle, currentYawAngle, 0);
        Vector3 desiredPos = calculatedTargetPos + targetRot * new Vector3(0, 0, -smoothZoomDistance);
        desiredPos.y = Mathf.Max(desiredPos.y, groundHeightLimit);

        transform.position = Vector3.Lerp(transform.position, desiredPos, Time.deltaTime * interpolationSmoothness);
        transform.rotation = Quaternion.Lerp(transform.rotation, targetRot, Time.deltaTime * interpolationSmoothness);
    }
}
