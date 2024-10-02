using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BasicEnemyManager : MonoBehaviour
{
    [Header("Dependencies")]
    [SerializeField] private SimpleEntityStateMachine enemyStateMachine;
    [SerializeField] private MovementPhysicsScript movementPhysics;
    [SerializeField] private AnimationManager animationManager;
    [SerializeField] private BasicEntity entity;
    [SerializeField] private EnemyBehavior enemyAI;
    [SerializeField] private Transform enemyTransform;

    private InputData inputData;

    private void Awake()
    {
        inputData = new InputData();
        State initialState = new EnemyIdleState(enemyStateMachine);
        enemyStateMachine.InitializeStateMachine(initialState, entity, animationManager, inputData, movementPhysics);
        enemyAI.Initialize(inputData, enemyTransform);
        entity.Initialize();
    }
}
