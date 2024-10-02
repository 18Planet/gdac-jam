using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProjectileScript : MonoBehaviour
{
    [Header("Dependencies")]
    [SerializeField] private Rigidbody2D rb;
    [SerializeField] private ProjectileProfile profile;

    private HashSet<BasicEntity> hitList = new HashSet<BasicEntity>();
    private float timer = 0f;

    public void Initialize(Vector2 direction)
    {
        rb.velocity = direction.normalized * profile.Velocity;
        timer = profile.Lifetime;
    }

    private void Update()
    {
        timer -= Time.deltaTime;
        if (timer <= 0f)
            Destroy(gameObject);
    }

    private void OnTriggerEnter2D(Collider2D other)
    {
        if((other.gameObject.layer ^ profile.TargetLayers.value) == 0)
        {
            var entity = other.gameObject.GetComponentInParent<BasicEntity>();
            if(entity != null && !hitList.Contains(entity))
            {
                hitList.Add(entity);
                entity.ReceiveDamage(new AttackData { 
                    damage = profile.Damage, 
                    knockbackDirection = rb.velocity, 
                    knockbackVelocity = profile.Knockback 
                });
                if(profile.DestroyOnDamage)
                {
                    Destroy(gameObject);
                    return;
                }
            }
        }
        if((other.gameObject.layer ^ profile.DestroyLayers.value) == 0)
        {
            Destroy(gameObject);
        }
    }
}
