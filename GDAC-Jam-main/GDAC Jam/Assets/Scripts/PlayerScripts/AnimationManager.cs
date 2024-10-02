using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationManager : MonoBehaviour
{
    [Header("Dependencies")]
    [SerializeField] private Animator animator;
    [SerializeField] private SpriteRenderer spriteRenderer;

    private int dir = 1;

    public void SetAnimation(string name, bool force = false)
    {
        if(!animator.GetCurrentAnimatorStateInfo(0).IsName(name) || force)
        {
            animator.Play(name);
        }
    }

    public void SetFlipDirection(float dir)
    {
        if (dir == 0)
            return;
        else
            this.dir = (int)Mathf.Sign(dir);
    }

    private void Update()
    {
        LerpToTargetFlip();
    }

    private void LerpToTargetFlip()
    {
        float currentX = spriteRenderer.transform.localScale.x;
        float newX = Mathf.MoveTowards(currentX, dir, Time.deltaTime * 10f);
        spriteRenderer.transform.localScale = new Vector3(newX, 1, 1);
    }

    public void SetSpeed(float val)
    {
        animator.speed = val;
    }

    public float GetCurrentStateDuration()
    {
        return animator.GetCurrentAnimatorStateInfo(0).length;
    }

    public void ForceUpdate()
    {
        animator.Update(0.01f);
    }
}
