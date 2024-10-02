using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "Projectiles/ProjectileProfile")]
public class ProjectileProfile : ScriptableObject
{
    [SerializeField] private float damage;
    [SerializeField] private float velocity;
    [SerializeField] private float knockback;
    [SerializeField] private float lifetime;
    [SerializeField] private LayerMask targetLayers;
    [SerializeField] private LayerMask destroyLayers;
    [SerializeField] private bool destroyOnDamage;

    public float Damage { get => damage;}
    public float Velocity { get => velocity;}
    public float Knockback { get => knockback;}
    public float Lifetime { get => lifetime;}
    public LayerMask TargetLayers { get => targetLayers;}
    public bool DestroyOnDamage { get => destroyOnDamage;}
    public LayerMask DestroyLayers { get => destroyLayers;}
}
