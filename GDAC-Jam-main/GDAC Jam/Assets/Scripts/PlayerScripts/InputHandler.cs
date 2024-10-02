using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
public class InputHandler : MonoBehaviour, DefaultControls.IDefaultActionMapActions
{
    [SerializeField] private DefaultControls controls;

    private InputData currentInputData;
    public InputData CurrentInputData => currentInputData;

    public void Initialize()
    {
        controls = new DefaultControls();
        controls.Enable();
        SetupEvents();
        currentInputData = new InputData();
    }

    private void SetupEvents()
    {
        controls.DefaultActionMap.SetCallbacks(this);
    }

    private void OnDestroy()
    {
        controls.Dispose();
    }

    public void OnMovement(InputAction.CallbackContext context)
    {
        currentInputData.MovementInput = context.ReadValue<Vector2>();
    }
}

public class InputData
{
    public Vector2 MovementInput { get; set; }

}

