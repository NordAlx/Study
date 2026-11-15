using UnityEngine;
using UnityEngine.AI;

[RequireComponent(typeof(AudioSource))]
public sealed class GhostPresentation : MonoBehaviour
{
    [SerializeField] private Animator animator;
    [SerializeField] private Transform visual;
    [SerializeField] private AudioSource approachSound;
    [SerializeField, Min(1f)] private float hearingDistance = 10f;

    private static readonly int Speed = Animator.StringToHash("Speed");

    private Transform player;
    private NavMeshAgent agent;
    private Quaternion restRotation;

    private void Awake()
    {
        restRotation = visual.localRotation;
    }

    public void Follow(Transform target, NavMeshAgent navigationAgent)
    {
        player = target;
        agent = navigationAgent;
        approachSound.volume = 0f;
        approachSound.Play();
    }

    private void LateUpdate()
    {
        if (player == null)
            return;

        Vector3 velocity = transform.InverseTransformDirection(agent.velocity);
        animator.SetFloat(Speed, velocity.magnitude);
        var lean = Quaternion.Euler(velocity.z * 5f, 0f, -velocity.x * 5f);
        visual.localRotation = Quaternion.Slerp(visual.localRotation, restRotation * lean,
            1f - Mathf.Exp(-12f * Time.deltaTime));

        float proximity = 1f - Mathf.Clamp01(Vector3.Distance(transform.position, player.position) / hearingDistance);
        approachSound.volume = 0.32f * proximity * proximity;
        approachSound.pitch = Mathf.Lerp(0.85f, 1.25f, proximity);
    }
}
