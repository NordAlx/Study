using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.XR;
using UnityEngine.UI;
using UnityEngine.XR;
using UnityEngine.XR.Management;

public sealed class MazeVrRig : MonoBehaviour
{
    [SerializeField] private MazePlayer player;
    [SerializeField] private MazeHud hud;
    [SerializeField] private Camera eye;
    [SerializeField] private Canvas canvas;
    [SerializeField] private Text hint;

    private XRManagerSettings manager;
    private InputAction walk;
    private InputAction look;
    private InputAction pause;
    private InputAction menu;
    private Transform origin;
    private float yaw = 90f;
    private float pitch = 8f;
    private bool headset;
    private bool turnReady = true;

    public bool Active => origin != null;

    private void Start()
    {
        var mode = MazeRunResult.View;
        if (mode == MazeRunResult.ViewMode.Desktop)
            return;

        origin = new GameObject("XR Origin").transform;
        origin.SetParent(player.transform, false);
        origin.localPosition = Vector3.up * 0.79f;
        origin.localRotation = Quaternion.Euler(0f, yaw, 0f);
        eye.transform.SetParent(origin, false);
        eye.transform.localPosition = Vector3.zero;
        eye.transform.localRotation = Quaternion.Euler(pitch, 0f, 0f);
        eye.orthographic = false;
        eye.fieldOfView = 65f;
        eye.nearClipPlane = 0.045f;
        eye.farClipPlane = 50f;
        foreach (var renderer in player.GetComponentsInChildren<Renderer>())
            renderer.enabled = false;

        if (mode == MazeRunResult.ViewMode.OpenXR)
            StartHeadset();

        hint.gameObject.SetActive(true);
        hint.text = headset ? "VR   Стик — движение   A — пауза   B — меню"
            : mode == MazeRunResult.ViewMode.OpenXR
                ? "Шлем недоступен   WASD — движение   Стрелки — обзор"
                : "VR · Симуляция   WASD — движение   Стрелки — обзор";
        walk = new InputAction("VR Walk", InputActionType.Value);
        walk.AddBinding("<XRController>{LeftHand}/primary2DAxis");
        walk.AddBinding("<Gamepad>/leftStick");
        look = new InputAction("VR Look", InputActionType.Value);
        look.AddBinding("<XRController>{RightHand}/primary2DAxis");
        look.AddBinding("<Gamepad>/rightStick");
        look.AddCompositeBinding("2DVector")
            .With("Up", "<Keyboard>/upArrow").With("Down", "<Keyboard>/downArrow")
            .With("Left", "<Keyboard>/leftArrow").With("Right", "<Keyboard>/rightArrow");
        pause = new InputAction("VR Pause", InputActionType.Button);
        pause.AddBinding("<XRController>{RightHand}/primaryButton");
        pause.AddBinding("<Gamepad>/start");
        menu = new InputAction("VR Menu", InputActionType.Button);
        menu.AddBinding("<XRController>{RightHand}/secondaryButton");
        menu.AddBinding("<Gamepad>/buttonEast");
        player.SetView(this);
        walk.Enable();
        look.Enable();
        pause.Enable();
        menu.Enable();
    }

    public Vector3 Movement(Vector2 keyboard)
    {
        Vector2 stick = walk.ReadValue<Vector2>();
        Vector2 input = stick.sqrMagnitude > 0.04f ? Vector2.ClampMagnitude(stick, 1f) : keyboard;
        Vector3 forward = Vector3.ProjectOnPlane(eye.transform.forward, Vector3.up);
        if (forward.sqrMagnitude < 0.01f)
            forward = origin.forward;
        forward.Normalize();
        return forward * input.y + Vector3.Cross(Vector3.up, forward) * input.x;
    }

    private void Update()
    {
        if (!Active)
            return;

        Vector2 turn = look.ReadValue<Vector2>();
        if (headset)
        {
            if (turnReady && Mathf.Abs(turn.x) >= 0.65f)
            {
                yaw += Mathf.Sign(turn.x) * 30f;
                turnReady = false;
            }
            else if (Mathf.Abs(turn.x) < 0.25f)
                turnReady = true;
        }
        else
        {
            yaw += turn.x * 90f * Time.unscaledDeltaTime;
            pitch = Mathf.Clamp(pitch - turn.y * 72f * Time.unscaledDeltaTime, -65f, 65f);
            eye.transform.localRotation = Quaternion.Euler(pitch, 0f, 0f);
        }

        origin.localRotation = Quaternion.Euler(0f, yaw, 0f);
        if (pause.WasPressedThisFrame())
            hud.TogglePause();
        if (hud.IsPaused && menu.WasPressedThisFrame())
            hud.OpenMenu();
    }

    private void StartHeadset()
    {
        manager = XRGeneralSettings.Instance?.Manager;
        if (manager == null)
            return;

        manager.InitializeLoaderSync();
        if (manager.activeLoader == null)
            return;

        manager.StartSubsystems();
        var displays = new List<XRDisplaySubsystem>();
        SubsystemManager.GetSubsystems(displays);
        headset = displays.Exists(display => display.running);
        if (!headset)
        {
            manager.StopSubsystems();
            manager.DeinitializeLoader();
            manager = null;
            return;
        }

        var inputs = new List<XRInputSubsystem>();
        SubsystemManager.GetSubsystems(inputs);
        foreach (var input in inputs)
            if (input.running)
                input.TrySetTrackingOriginMode(TrackingOriginModeFlags.Device);

        eye.transform.localRotation = Quaternion.identity;
        eye.stereoTargetEye = StereoTargetEyeMask.Both;
        var trackedPose = eye.gameObject.AddComponent<TrackedPoseDriver>();
        trackedPose.positionInput = new InputActionProperty(new InputAction(binding: "<XRHMD>/centerEyePosition"));
        trackedPose.rotationInput = new InputActionProperty(new InputAction(binding: "<XRHMD>/centerEyeRotation"));

        canvas.renderMode = RenderMode.WorldSpace;
        canvas.worldCamera = eye;
        var rect = (RectTransform)canvas.transform;
        rect.SetParent(eye.transform, false);
        rect.sizeDelta = new Vector2(960f, 540f);
        rect.localPosition = new Vector3(0f, 0f, 1.25f);
        rect.localRotation = Quaternion.identity;
        rect.localScale = Vector3.one * 0.0011f;
    }

    private void OnDestroy()
    {
        walk?.Dispose();
        look?.Dispose();
        pause?.Dispose();
        menu?.Dispose();
        if (manager?.activeLoader != null)
        {
            manager.StopSubsystems();
            manager.DeinitializeLoader();
        }
    }
}
