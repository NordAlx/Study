using UnityEngine;

[RequireComponent(typeof(SphereCollider))]
public sealed class CoinPickup : MonoBehaviour
{
    [SerializeField] private ParticleSystem pickupEffect;

    private bool collected;

    private void OnTriggerEnter(Collider other)
    {
        Rigidbody body = other.attachedRigidbody;
        if (collected || body == null || !body.TryGetComponent(out MazePlayer player))
            return;

        collected = true;
        player.AddCoin();
        if (pickupEffect != null)
            Instantiate(pickupEffect, transform.TransformPoint(GetComponent<SphereCollider>().center), Quaternion.identity);
        Destroy(gameObject);
    }
}
