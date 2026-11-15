using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent(typeof(Rigidbody), typeof(CapsuleCollider))]
public sealed class MazePlayer : MonoBehaviour
{
    [SerializeField, Min(0.1f)] private float moveSpeed = 4f;
    [SerializeField, Min(1)] private int maxHealth = 3;
    [SerializeField] private int currentHealth;
    [SerializeField] private int coinsCollected;

    public int MaxHealth => maxHealth;
    public int CurrentHealth => currentHealth;
    public int CoinsCollected => coinsCollected;

    private Rigidbody body;
    private InputAction move;
    private MazeVrRig vr;

    public void SetView(MazeVrRig view) => vr = view;

    private void Awake()
    {
        body = GetComponent<Rigidbody>();
    }

    public void Initialize(Vector3 spawnPosition)
    {
        body = GetComponent<Rigidbody>();
        body.position = spawnPosition;
        body.linearVelocity = Vector3.zero;
        currentHealth = maxHealth;
        coinsCollected = 0;
    }

    private void OnEnable()
    {
        move = new InputAction("Move", InputActionType.Value);
        move.AddCompositeBinding("2DVector")
            .With("Up", "<Keyboard>/w")
            .With("Down", "<Keyboard>/s")
            .With("Left", "<Keyboard>/a")
            .With("Right", "<Keyboard>/d");
        move.Enable();
    }

    private void OnDisable()
    {
        move.Dispose();
        if (body != null)
            body.linearVelocity = Vector3.zero;
    }

    private void FixedUpdate()
    {
        Vector2 input = currentHealth > 0 ? move.ReadValue<Vector2>() : Vector2.zero;
        Vector3 direction = vr != null && vr.Active ? vr.Movement(input) : new Vector3(input.x, 0f, input.y);
        body.linearVelocity = currentHealth > 0 ? direction * moveSpeed : Vector3.zero;
    }

    public void AddCoin()
    {
        coinsCollected++;
    }

    public void TakeHit()
    {
        currentHealth = Mathf.Max(0, currentHealth - 1);
    }
}
