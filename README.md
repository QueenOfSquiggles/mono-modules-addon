# Mono Modules Addon

Created by QueenOfSquiggles with <3


## Purpose
One glaring issue coming from Unity to Godot is that Godot doesn't have a clean GUI interface for managing C# modules. In Unity there are called Assemblies (AssemblyDef)

This addon creates a custom resource which make generating "modules" very easy. 

## Requirements
The feature that adds the module reference to the main project solution file is performed using a dotnet sdk shell command. This means you will need a dotnet sdk installed on your system for that to work properly. This is generally expected if you are using C# in general, so I imagine this isn't asking much.

## Definitons

#### Module
- A single, contained chunk of code that can be compiled independently of other Modules. 
- Requires explicit references to outside dependencies
- C# term of "Class Library" is roughly equivalent
- [See also, explanation of 'Modularization'](http://www.codingcris.com/what-is-modularization/)

#### ModuleDef
- A Godot Resource type added by this addon.
- Manages a `.csproj` file in the same directory as it.
- If no `.csproj` file is found, it will prompt in-editor to generate one
- Allows for adding and removing dependencies through the Godot editor.
- Buttons for Refreshing data, Opening containing folder, and Opening `.csproj` directly in the system default text editor

## Instructions for Use

### Quick-Start

*Getting you quickly up and running with the addon*

1. Install the addon by copying the "addons" folder in this repository to your project file
2. Enable the plugin by going to "Project" > "Project Settings" > "Plugins" and check the "Enable" check box next to this plugin's name "MonoModulesAddon"
3. Create a ModuleDef in any non-root folder in your project (needs to be in a folder!!!) by right clicking on the folder and selecting "New Resource.."
    - Search by typing "ModuleDef" into the search bar and click the matching option
    - A prompt will request file to save it as. Save as a ".tres" file in the folder of your choosing. Name it what you would like the `.csproj` file to be named.
4. Click on the created ModuleDef. A button at the top of the inspector should appear suggesting to "Add to Project Solution". Click on that button
5. A prompt should appear showing whether it was successful.
    - If it failed, double check you have a dotnet SDk installed with `dotnet --info`
6. Now when building your project, the folder which contains your ModuleDef and all subfolders will be compiled as a single unit before compiling the rest of the project
7. Repeat Steps 3-5 as many times as desired for each individual module.

### Dependencies

*Adding dependencies to a ModuleDef created from the Quick-Start*

1. Click on the desired ModuleDef
2. Click on the "Dependencies" button
3. Click on the "+" button
4. A file dialog will appear for selecting a `.csproj` file (A ModuleDef for managing the `.csproj` is not required)
5. Select the desired dependency
6. It should appear in the dependency list for the ModuleDef

*Removing unwanted dependencies*

1. Click on the desired ModuleDef
2. Click on the "Dependencies" button
3. Find the dependency which you would like to remove
4. Click on the "-" button on the dependency
5. If the ModuleDef doesn't update immediately, click the "Refresh" button at the top. (Icon only button)





