using UnityEngine;

// 날짜 : 2021-09-26 PM 8:59:19
// 작성자 : Rito

/// <summary> 
/// 큐브 위치, 색상 시뮬레이션
/// </summary>
public class CubeSimulator : MonoBehaviour
{
    private struct Cube
    {
        public Vector3 position;
        public Color color;
    }

    [Tooltip("true : 컴퓨트 쉐이더 사용 / false : CPU 사용")]
    [SerializeField] private bool useComputeShader = true;

    [Space]
    [SerializeField] private ComputeShader computeShader;
    [SerializeField] private Material cubeMaterial;

    [Space]
    [Range(0f, 100f)]
    [SerializeField] private float updateSpeed = 10f;
    [Range(0f, 2f)]
    [SerializeField] private float waveFrequency = 0.5f;

    [Space]
    [SerializeField] private float cubePositionInterval = 1f;
    [SerializeField] private float cubeScale = 1f;
    [SerializeField] private int rowSize = 64; // 행, 열 크기

    private MeshRenderer[] _cubeRenderers;
    private Transform[] _cubeTransforms;
    private Cube[] _cubeDatas;

    private MaterialPropertyBlock _mpb;
    private ComputeBuffer _cubeBuffer;
    private int _cubeCount;

    /***********************************************************************
    *                               Unity Events
    ***********************************************************************/
    #region .
    private void Start()
    {
        Init();
        CreateCubes();
        InitComputeShaderData();
    }
    private void Update()
    {
        if (useComputeShader)
        {
            DispatchComputeShader();
            GetDataFromComputeShader();
        }
        else
        {
            UpdateCPU();
        }
    }
    private void OnDestroy()
    {
        _cubeBuffer.Release();
    }
    #endregion
    /***********************************************************************
    *                               Init Methods
    ***********************************************************************/
    #region .
    private void Init()
    {
        _mpb = new MaterialPropertyBlock();
    }

    /// <summary> 정방형 분포 큐브들 생성 </summary>
    /// lineCount : 행, 열 개수
    private void CreateCubes()
    {
        _cubeCount = rowSize * rowSize;
        _cubeRenderers = new MeshRenderer[_cubeCount];
        _cubeTransforms = new Transform[_cubeCount];
        _cubeDatas = new Cube[_cubeCount];

        for (int j = 0; j < rowSize; j++)
        {
            for (int i = 0; i < rowSize; i++)
            {
                // 큐브 게임오브젝트 생성
                var goCube = GameObject.CreatePrimitive(PrimitiveType.Cube);
                Transform trCube = goCube.transform;
                trCube.localScale = Vector3.one * cubeScale;
                trCube.localPosition = new Vector3(i * cubePositionInterval, 0f, j * cubePositionInterval);

                // 리스트에 추가
                _cubeTransforms[j * rowSize + i] = trCube;

                MeshRenderer mrCube = goCube.GetComponent<MeshRenderer>();
                if (mrCube != null)
                {
                    mrCube.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
                    mrCube.material = cubeMaterial;
                    _cubeRenderers[j * rowSize + i] = mrCube;
                }
            }
        }
    }

    private void InitComputeShaderData()
    {
        // Cube[] 배열 데이터 생성
        for (int i = 0; i < _cubeCount; i++)
        {
            _cubeDatas[i] = new Cube() { position = _cubeRenderers[i].transform.position };
        }

        // 컴퓨트 버퍼 객체 생성
        _cubeBuffer = new ComputeBuffer(_cubeCount, sizeof(float) * 7);
        _cubeBuffer.SetData(_cubeDatas);

        // 컴퓨트 쉐이더에 컴퓨트 버퍼 등록
        computeShader.SetBuffer(0, "cubeBuffer", _cubeBuffer);
    }
    #endregion
    /***********************************************************************
    *                               Update Methods
    ***********************************************************************/
    #region .
    private void UpdateCPU()
    {
        float t = Time.time * updateSpeed;
        float t2 = t * 0.5f;

        for (int j = 0; j < rowSize; j++)
        {
            for (int i = 0; i < rowSize; i++)
            {
                int index = j * rowSize + i;
                Transform tran = _cubeTransforms[index];
                Vector3 pos = tran.position;

                // Position
                float wave = (i + t) * waveFrequency;
                pos.y = Mathf.Sin(wave);
                tran.position = pos;

                // Color
                float k = Mathf.Sin((float)i / rowSize + t2) * 0.5f + 0.5f;
                _mpb.SetColor("_Color", Color.Lerp(Color.red, Color.blue, k));
                _cubeRenderers[index].SetPropertyBlock(_mpb);
            }
        }
    }

    private void DispatchComputeShader()
    {
        // 컴퓨트 쉐이더에 변수 값 등록
        computeShader.SetFloat("time", Time.time);
        computeShader.SetFloat("updateSpeed", updateSpeed);
        computeShader.SetFloat("rowSize", rowSize);
        computeShader.SetFloat("waveFrequency", waveFrequency);
        
        // 스레드 그룹 개수 계산
        computeShader.GetKernelThreadGroupSizes(0, out uint numX, out _, out _);
        int numThreadGroups = Mathf.CeilToInt((float)_cubeCount / numX);

        // 컴퓨트 쉐이더 실행
        computeShader.Dispatch(0, numThreadGroups, 1, 1);
    }

    private void GetDataFromComputeShader()
    {
        // 컴퓨트 버퍼로부터 데이터 읽어오기
        _cubeBuffer.GetData(_cubeDatas);

        // 읽어온 데이터(위치, 색상) 적용
        for (int i = 0; i < _cubeCount; i++)
        {
            _cubeTransforms[i].position = _cubeDatas[i].position;

            _mpb.SetColor("_Color", _cubeDatas[i].color);
            _cubeRenderers[i].SetPropertyBlock(_mpb);
        }
    }
    #endregion
}