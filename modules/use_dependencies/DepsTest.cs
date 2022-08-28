using Godot;
using System;
using modules.contracts;
using modules.transformExtension;

namespace modules.useDependencies
{

    class Sword : IItem
    {
        public void ApplyChanges()
        {
            GD.Print("Sword->ApplyChanges");
        }

        public string GetHostName()
        {
            return "Sword";
        }
    }
    public class DepsTest : Node
    {
        public override void _Ready()
        {
            IItem item = new Sword();
            item.ApplyChanges();
            var name = item.GetHostName();
            GD.Print("IItem->GetHostName : \""+name+"\"");

            var transform = new Transform();
            transform.Forward();
        }
    }
}
