using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ContactDamage : MonoBehaviour
{
    public float damage;
    public float knockbackVel;
    public LayerMask mask;

    private void OnTriggerStay2D(Collider2D other)
    {
        int bitLayer = 1 << other.gameObject.layer;
        if ((bitLayer & mask.value) == bitLayer)
        {
            var entity = other.gameObject.GetComponentInParent<BasicEntity>();
            if (entity != null)
            {                
                entity.ReceiveDamage(new AttackData
                {
                    damage = damage,
                    knockbackDirection =  other.transform.position - transform.position,
                    knockbackVelocity = knockbackVel
                });
            }
        }
    }
}
