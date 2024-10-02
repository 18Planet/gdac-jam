using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovementPhysicsScript : MonoBehaviour
{
    [Header("Dependencies")]
    [SerializeField] private Rigidbody2D rb;
    [SerializeField] private MovementStatProfile profile;

    public Vector2 RbVel
    {
        get => rb.velocity;
        set { rb.velocity = value; }
    }

    public Rigidbody2D Rb => rb;

    public void ApplyFixedFriction()
    {
        ApplyFixedFriction(profile.FrictionAcceleration);
    }
    public void ApplyFixedFriction(float accel)
    {
        RbVel = Vector2.MoveTowards(RbVel, Vector2.zero, accel * Time.fixedDeltaTime);
    }

    public void MoveInDirection(Vector2 directionNormalized)
    {
        Vector2 targetVel = directionNormalized * profile.MovementSpeed;
        Vector2 newVel = Vector2.MoveTowards(RbVel, targetVel, profile.Acceleration * Time.fixedDeltaTime);
        RbVel = newVel;
    }

    public float MaxSpeed()
    {
        return profile.MovementSpeed;
    }

    public void StopMovement()
    {
        RbVel = Vector2.zero;
    }
}
