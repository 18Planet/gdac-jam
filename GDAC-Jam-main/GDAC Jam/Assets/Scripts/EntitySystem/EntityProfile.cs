using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "Entity/EntityProfile")]
public class EntityProfile : ScriptableObject
{
    [SerializeField] private float maxHealth;
    [SerializeField] private float globalIFrameDuration;

    public float MaxHealth { get => maxHealth; set => maxHealth = value; }
    public float GlobalIFrameDuration { get => globalIFrameDuration; set => globalIFrameDuration = value; }
}
