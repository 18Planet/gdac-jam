using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BasicEntity : MonoBehaviour
{
    [Header("Dependencies")]
    [SerializeField] private EntityProfile profile;
    [SerializeField] private string entityTag;

    public string EntityTag => entityTag;

    private float currentHealth;
    private float iFrameDuration = 0f;

    // Events
    public System.Action<AttackData, float> OnDamageReceived;

    public void Initialize()
    {
        currentHealth = profile.MaxHealth;
    }

    private void Update()
    {
        if (iFrameDuration > 0f)
            iFrameDuration -= Time.deltaTime;
    }

    public void ReceiveDamage(AttackData attackData)
    {
        if (iFrameDuration > 0f)
            return;
        iFrameDuration = profile.GlobalIFrameDuration;
        currentHealth -= attackData.damage;
        OnDamageReceived?.Invoke(attackData, currentHealth);
    }

    public void SetIFrameDuration(float val)
    {
        iFrameDuration = val;
    }
   
}

public struct AttackData
{
    public float damage;
    public Vector2 knockbackDirection;
    public float knockbackVelocity;
}
