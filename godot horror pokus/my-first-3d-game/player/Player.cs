using Godot;
using System;

public partial class Player : CharacterBody3D
{
	private const float Speed = 30f;
	private const float JumpVelocity = 10.0f;
	private const float Gravity = 20.0f;
	private const float MouseSensitivityX = 0.4f;
	private const float MouseSensitivityY = 0.15f;

	private PackedScene _bulletScene;

	public override void _Ready()
	{
		Input.MouseMode = Input.MouseModeEnum.Captured;
		
		// Načítání scény musí být uvnitř metody
		_bulletScene = GD.Load<PackedScene>("res://player/bullet_3d.tscn");
	}

	public override void _UnhandledInput(InputEvent @event)
	{
		if (@event is InputEventMouseMotion mouseMotion)
		{
			Vector3 rotationDegrees = RotationDegrees;
			rotationDegrees.Y -= mouseMotion.Relative.X * MouseSensitivityX;
			RotationDegrees = rotationDegrees;

			var camera = GetNode<Camera3D>("%Camera3D");
			Vector3 camRot = camera.RotationDegrees;
			camRot.X -= mouseMotion.Relative.Y * MouseSensitivityY;
			camRot.X = Mathf.Clamp(camRot.X, -80.0f, 80.0f);
			camera.RotationDegrees = camRot;
		}
		else if (@event.IsActionPressed("ui_cancel"))
		{
			Input.MouseMode = Input.MouseModeEnum.Visible;
		}
	}

	public override void _PhysicsProcess(double delta)
	{
		Vector3 currentVelocity = Velocity;

		Vector2 inputDir = Input.GetVector("move_left", "move_right", "move_forward", "move_back");
		Vector3 direction = (Transform.Basis * new Vector3(inputDir.X, 0, inputDir.Y)).Normalized();

		if (direction != Vector3.Zero)
		{
			currentVelocity.X = direction.X * Speed;
			currentVelocity.Z = direction.Z * Speed;
		}
		else
		{
			currentVelocity.X = Mathf.MoveToward(Velocity.X, 0, Speed);
			currentVelocity.Z = Mathf.MoveToward(Velocity.Z, 0, Speed);
		}

		currentVelocity.Y -= Gravity * (float)delta;

		if (Input.IsActionJustPressed("jump") && IsOnFloor())
		{
			currentVelocity.Y = JumpVelocity;
		}
		else if (Input.IsActionJustReleased("jump") && currentVelocity.Y > 0)
		{
			currentVelocity.Y = 0;
		}

		Velocity = currentVelocity;
		MoveAndSlide();

		var timer = GetNode<Timer>("%Timer");
		if (Input.IsActionPressed("shoot") && timer.IsStopped())
		{
			ShootBullet();
		}
	}

	private void ShootBullet()
	{
		var marker = GetNode<Marker3D>("%Marker3D");
		var timer = GetNode<Timer>("%Timer");
		
		Node3D newBullet = (Node3D)_bulletScene.Instantiate();
		marker.AddChild(newBullet);
		newBullet.GlobalTransform = marker.GlobalTransform;
		timer.Start();
	}
}
