using UnityEngine;
using UnityEngine.UI;

public sealed class MazeResultScreen : MonoBehaviour
{
    [SerializeField] private Text heading;
    [SerializeField] private Text coinValue;
    [SerializeField] private Text healthValue;
    [SerializeField] private Color winColor;
    [SerializeField] private Color lossColor;

    private void Start()
    {
        if (!MazeRunResult.Last.HasValue)
        {
            heading.text = "Нет результата";
            coinValue.text = "—";
            healthValue.text = "—";
            return;
        }

        MazeRunResult result = MazeRunResult.Last.Value;
        heading.text = result.Won ? "Победа" : "Поражение";
        heading.color = result.Won ? winColor : lossColor;
        coinValue.text = $"{result.Coins} / {result.TotalCoins}";
        healthValue.text = result.Health.ToString();
    }
}
