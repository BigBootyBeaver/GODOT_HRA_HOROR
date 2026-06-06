using Godot;
using System;

[Tool]
public partial class TreeMerger : Node
{
	[Export] public MeshInstance3D KmenNode { get; set; }
	[Export] public MeshInstance3D KorunaNode { get; set; }

	private bool _spustitSpojeni = false;
	
	[Export]
	public bool SpustitSpojeni
	{
		get => _spustitSpojeni;
		set
		{
			_spustitSpojeni = value;
			if (_spustitSpojeni)
			{
				// Resetujeme tlačítko zpět na false v inspektoru
				_spustitSpojeni = false;
				ExportujStrom();
			}
		}
	}

	private void ExportujStrom()
	{
		if (KmenNode == null || KorunaNode == null)
		{
			GD.PrintErr("Chybí přiřazený kmen nebo koruna!");
			return;
		}

		if (KmenNode.Mesh == null || KorunaNode.Mesh == null)
		{
			GD.PrintErr("Jeden z uzlů nemá platný Mesh!");
			return;
		}

		var novyMesh = new ArrayMesh();
		var st = new SurfaceTool();

		// 1. PLOCHA: Kmen (Surface 0)
		st.Begin(Mesh.PrimitiveType.Triangles);
		st.AppendFrom(KmenNode.Mesh, 0, KmenNode.Transform);
		novyMesh = st.Commit(novyMesh);
		
		var matKmen = KmenNode.GetActiveMaterial(0);
		if (matKmen != null)
		{
			novyMesh.SurfaceSetMaterial(0, matKmen);
		}
		st.Clear();

		// 2. PLOCHA: Koruna (Surface 1)
		st.Begin(Mesh.PrimitiveType.Triangles);
		st.AppendFrom(KorunaNode.Mesh, 0, KorunaNode.Transform);
		novyMesh = st.Commit(novyMesh);
		
		var matKoruna = KorunaNode.GetActiveMaterial(0);
		if (matKoruna != null)
		{
			novyMesh.SurfaceSetMaterial(1, matKoruna);
		}

		// Uložení výsledného souboru na disk
		string ulozenieCesta = "res://hotovy_strom.mesh";
		Error chyba = ResourceSaver.Save(novyMesh, ulozenieCesta);

		if (chyba == Error.Ok)
		{
			GD.Print($"HOTOVO! Soubor {ulozenieCesta} byl vytvořen se 2 plochami.");
		}
		else
		{
			GD.PrintErr($"Chyba při ukládání meshe: {chyba}");
		}
	}
}
