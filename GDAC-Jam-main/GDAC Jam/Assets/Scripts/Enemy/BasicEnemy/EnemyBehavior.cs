using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class EnemyBehavior : MonoBehaviour
{
    protected InputData inputDataOutput;
    protected Transform physicsBody;

    protected Transform targetTransform;

    public void Initialize(InputData AIOutput, Transform physicsBody)
    {
        inputDataOutput = AIOutput;
        targetTransform = GameObject.FindGameObjectWithTag("Player").transform;
        this.physicsBody = physicsBody;
    }


    private void Update()
    {
        UpdateBehavior();
    }

    public abstract void UpdateBehavior();
    
}
