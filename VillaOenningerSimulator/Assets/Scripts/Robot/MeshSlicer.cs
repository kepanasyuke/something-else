using UnityEngine;
using System.Collections.Generic;

public static class MeshSlicer
{
    public static GameObject[] Slice(GameObject target, Vector3 planePos, Vector3 planeNormal, Material capMat)
    {
        var filter = target.GetComponent<MeshFilter>();
        if (filter == null) return null;

        Mesh mesh = filter.sharedMesh;
        Plane plane = new Plane(target.transform.InverseTransformDirection(planeNormal),
                                target.transform.InverseTransformPoint(planePos));

        var leftVerts = new List<Vector3>();
        var rightVerts = new List<Vector3>();
        var leftTris = new List<int>();
        var rightTris = new List<int>();

        Vector3[] verts = mesh.vertices;
        int[] tris = mesh.triangles;
        bool[] isLeft = new bool[verts.Length];
        for (int i = 0; i < verts.Length; i++) isLeft[i] = plane.GetSide(verts[i]);

        for (int i = 0; i < tris.Length; i += 3)
        {
            int a = tris[i], b = tris[i+1], c = tris[i+2];
            if (isLeft[a] && isLeft[b] && isLeft[c])
            {
                leftVerts.Add(verts[a]); leftVerts.Add(verts[b]); leftVerts.Add(verts[c]);
                leftTris.Add(leftTris.Count); leftTris.Add(leftTris.Count); leftTris.Add(leftTris.Count);
            }
            else
            {
                rightVerts.Add(verts[a]); rightVerts.Add(verts[b]); rightVerts.Add(verts[c]);
                rightTris.Add(rightTris.Count); rightTris.Add(rightTris.Count); rightTris.Add(rightTris.Count);
            }
        }

        if (leftVerts.Count == 0 || rightVerts.Count == 0) return null;

        return new GameObject[]
        {
            CreateHalf(target, "Slice_Left", leftVerts, leftTris, capMat),
            CreateHalf(target, "Slice_Right", rightVerts, rightTris, capMat)
        };
    }

    private static GameObject CreateHalf(GameObject original, string name, List<Vector3> verts, List<int> tris, Material mat)
    {
        GameObject half = new GameObject(name);
        half.transform.SetPositionAndRotation(original.transform.position, original.transform.rotation);
        half.transform.localScale = original.transform.localScale;

        Mesh m = new Mesh();
        m.vertices = verts.ToArray();
        m.triangles = tris.ToArray();
        m.RecalculateNormals();
        m.RecalculateBounds();

        half.AddComponent<MeshFilter>().mesh = m;
        half.AddComponent<MeshRenderer>().sharedMaterial = mat;

        var collider = half.AddComponent<MeshCollider>();
        collider.convex = true;
        half.AddComponent<Rigidbody>().mass = 10f;

        half.tag = "Destructible";
        int debrisLayer = LayerMask.NameToLayer("Debris");
        if (debrisLayer != -1) half.layer = debrisLayer;
        return half;
    }
}
