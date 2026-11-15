using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

[RequireComponent(typeof(MazeGenerator))]
public sealed class MazeNavigation : MonoBehaviour
{
    [SerializeField] private BoxCollider floor;
    [SerializeField] private bool navMeshReady;

    private NavMeshData data;
    private NavMeshDataInstance instance;
    private NavMeshAgent ghostAgent;
    private NavMeshTriangulation preview;

    public void Build(Transform walls, MazeGhost ghost, MazePlayer player)
    {
        if (floor == null)
        {
            Debug.LogError("Assign the maze floor collider to Maze Navigation.", this);
            return;
        }

        var settings = NavMesh.GetSettingsByIndex(0);
        settings.agentRadius = 0.23f;
        settings.agentHeight = 1.2f;
        settings.agentClimb = 0.08f;
        settings.overrideVoxelSize = true;
        settings.voxelSize = 0.06f;

        var sources = new List<NavMeshBuildSource> { SourceFor(floor) };
        Bounds bounds = floor.bounds;
        foreach (var wall in walls.GetComponentsInChildren<BoxCollider>())
        {
            sources.Add(SourceFor(wall));
            bounds.Encapsulate(wall.bounds);
        }
        bounds.Expand(2f);

        data = NavMeshBuilder.BuildNavMeshData(settings, sources, bounds, Vector3.zero, Quaternion.identity);
        if (data == null)
        {
            Debug.LogError("Unity could not build the maze NavMesh.", this);
            return;
        }

        instance = NavMesh.AddNavMeshData(data);
        navMeshReady = instance.valid && ghost.BeginChase(player);
        if (navMeshReady)
        {
            ghostAgent = ghost.GetComponent<NavMeshAgent>();
            preview = NavMesh.CalculateTriangulation();
        }
    }

    private static NavMeshBuildSource SourceFor(BoxCollider collider)
    {
        return new NavMeshBuildSource
        {
            shape = NavMeshBuildSourceShape.Box,
            transform = collider.transform.localToWorldMatrix * Matrix4x4.Translate(collider.center),
            size = collider.size,
            area = 0
        };
    }

    private void OnDestroy()
    {
        if (instance.valid)
            instance.Remove();
        if (data != null)
            Destroy(data);
    }

    private void OnDrawGizmosSelected()
    {
        if (!navMeshReady || floor == null)
            return;

        var mesh = preview;
        float floorHeight = floor.bounds.max.y + 0.15f;
        var offset = Vector3.up * 0.04f;
        Gizmos.color = new Color(0.2f, 1f, 0.85f, 1f);
        for (int i = 0; i < mesh.indices.Length; i += 3)
        {
            Vector3 a = mesh.vertices[mesh.indices[i]];
            Vector3 b = mesh.vertices[mesh.indices[i + 1]];
            Vector3 c = mesh.vertices[mesh.indices[i + 2]];
            if (a.y > floorHeight || b.y > floorHeight || c.y > floorHeight)
                continue;

            Gizmos.DrawLine(a + offset, b + offset);
            Gizmos.DrawLine(b + offset, c + offset);
            Gizmos.DrawLine(c + offset, a + offset);
        }

        if (ghostAgent == null || !ghostAgent.isOnNavMesh || !ghostAgent.hasPath)
            return;

        Vector3[] points = ghostAgent.path.corners;
        Gizmos.color = new Color(1f, 0.77f, 0.25f);
        for (int i = 1; i < points.Length; i++)
            Gizmos.DrawLine(points[i - 1] + Vector3.up * 0.12f, points[i] + Vector3.up * 0.12f);
    }
}
