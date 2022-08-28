using Godot;
using System;

namespace modules.transformExtension
{
    public static class TransformEx
    {
        public static Vector3 Forward(this Transform trans)
        {
            return -trans.basis.z;
        }
    }

}

