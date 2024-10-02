using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "ConfigObjects/MovementProfile")]
public class MovementStatProfile : ScriptableObject
{
    [Header("Movement")]
    [SerializeField] private float movementSpeed;
    [SerializeField] private float acceleration;
    [SerializeField] private float frictionAcceleration;

    public float MovementSpeed { get => movementSpeed; set => movementSpeed = value; }
    public float Acceleration { get => acceleration; set => acceleration = value; }
    public float FrictionAcceleration { get => frictionAcceleration; set => frictionAcceleration = value; }
}
