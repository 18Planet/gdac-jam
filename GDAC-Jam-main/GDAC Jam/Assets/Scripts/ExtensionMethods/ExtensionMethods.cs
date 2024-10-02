using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class ExtensionMethods 
{
    public static Vector3 ToVec3XY(this Vector2 vec)
    {
        return new Vector3(vec.x, vec.y, 0);
    }

    public static Vector2 ProjectXYPlane(this Vector3 vec)
    {
        return new Vector2(vec.x, vec.y);
    }
}
