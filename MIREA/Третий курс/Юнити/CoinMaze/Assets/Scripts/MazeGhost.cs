using UnityEngine;
using UnityEngine.AI;

[RequireComponent(typeof(NavMeshAgent), typeof(CapsuleCollider))]
public sealed class MazeGhost : MonoBehaviour
{
    [SerializeField, Min(0.05f)] private float repathInterval = 0.2f;
    [SerializeField] private NavMeshPathStatus pathStatus = NavMeshPathStatus.PathInvalid;

    private NavMeshAgent agent;
    private MazePlayer target;
    private float nextRepath;

    public bool BeginChase(MazePlayer player)
    {
        agent = GetComponent<NavMeshAgent>();
        if (!NavMesh.SamplePosition(transform.position, out var start, 0.6f, agent.areaMask))
        {
            Debug.LogError("The ghost's spawn point is outside the maze NavMesh.", this);
            return false;
        }

        transform.position = start.position;
        agent.enabled = true;
        agent.updateRotation = false;
        if (!agent.Warp(start.position))
        {
            Debug.LogError("The ghost could not enter the maze NavMesh.", this);
            return false;
        }

        target = player;
        if (TryGetComponent(out GhostPresentation presentation))
            presentation.Follow(player.transform, agent);
        return true;
    }

    private void Update()
    {
        if (target == null || !agent.isOnNavMesh)
            return;

        pathStatus = agent.pathStatus;
        if (target.CurrentHealth == 0)
        {
            agent.ResetPath();
            return;
        }

        if (Time.time < nextRepath)
            return;

        nextRepath = Time.time + repathInterval;
        if (NavMesh.SamplePosition(target.transform.position, out var destination, 0.55f, agent.areaMask))
            agent.SetDestination(destination.position);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (target != null && other.attachedRigidbody != null
            && other.attachedRigidbody.TryGetComponent(out MazePlayer player) && player == target)
            player.TakeHit();
    }
}
