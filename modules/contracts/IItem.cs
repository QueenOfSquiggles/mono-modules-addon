using Godot;
using System;

namespace modules.contracts 
{
    public interface IItem
    {
        string GetHostName();
        void ApplyChanges();

    }

}
