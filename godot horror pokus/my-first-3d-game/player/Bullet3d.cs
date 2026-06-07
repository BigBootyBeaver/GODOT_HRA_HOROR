using Godot;
using System;

public partial class Bullet3d : Area3D
{
	private const float Speed = 15.0f;
	private const float Range = 40.0f;
	private float _travelledDistance = 0.0f;

	public override void _Ready()
	{
		BodyEntered += OnBodyEntered;
	}
	
	public override void _Process(double delta)
	{
		_PhysicsProcess(delta);
	}

	// POZOR: Musí zde být "double delta", jinak se pohyb nespustí!
	public override void _PhysicsProcess(double delta)
	{
		// GD.Print("Kulka zije!");
		float floatDelta = (float)delta;
		float distanceThisFrame = Speed * floatDelta;

		// Pohyb v globálním prostoru směrem dopředu
		Vector3 direction = -GlobalTransform.Basis.Z;
		GlobalPosition += direction * distanceThisFrame;

		_travelledDistance += distanceThisFrame;

		if (_travelledDistance > Range)
		{
			QueueFree();
		}
	}
	private void OnBodyEntered(Node3D body)
	{
		QueueFree();
		if (body.HasMethod("take_damage"))
	{
		body.Call("take_damage");
	}
	}
}
