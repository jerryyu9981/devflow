(function() {
  /* ── Read CSS Variables ── */
  var style = getComputedStyle(document.documentElement);
  var accent  = style.getPropertyValue('--accent').trim()  || '#4B3FE3';
  var accent2 = style.getPropertyValue('--accent2').trim() || '#22A5F7';
  var ink     = style.getPropertyValue('--ink').trim()     || '#1A1A2E';
  var muted   = style.getPropertyValue('--muted').trim()   || '#6B7280';
  var rule    = style.getPropertyValue('--rule').trim()    || '#E5E7EB';
  var bg2     = style.getPropertyValue('--bg2').trim()     || '#F7F8FA';

  /* ── Color palette for heatmap ── */
  var noneColor  = '#f0f0f0';
  var lowColor   = '#FEF3C7';   /* amber-100 */
  var highColor  = '#86EFAC';   /* green-300 */

  /* ── Common heatmap formatter ── */
  function heatLabel(val) {
    if (val === 0) return '无';
    if (val === 1) return '间接';
    if (val === 2) return '有';
    return String(val);
  }

  /* ── Shared axis config ── */
  var axisLabelStyle = {
    fontSize: 12,
    fontFamily: "'InstrumentSans', 'WorkSans', sans-serif",
    color: ink
  };

  /* ── Build visual map ── */
  function makeVisualMap() {
    return {
      min: 0,
      max: 2,
      calculable: false,
      orient: 'horizontal',
      left: 'center',
      bottom: 0,
      inRange: {
        color: [noneColor, lowColor, highColor]
      },
      formatter: function(val) { return heatLabel(val); },
      textStyle: { color: muted, fontSize: 11 }
    };
  }

  /* ── Chart 1: coverage-heatmap ── */
  function initCoverageHeatmap() {
    var el = document.getElementById('coverage-heatmap');
    if (!el) return;
    var chart = echarts.init(el, null, { renderer: 'svg' });

    var rows = [
      '需求触发与场景定义',
      '候选方案调研与筛选',
      '量化评分与对比',
      'POC / Spike 验证',
      'ADR 决策记录',
      '团队评审与共识',
      '持续追踪与演进'
    ];
    var cols = ['Step 0', 'Step 1', 'Step 2', 'L3 技能', '审计/门禁'];

    var data = [
      /* 需求触发 */        [0, 0, 1, 0, 0],
      /* 候选方案调研 */    [0, 0, 1, 0, 0],
      /* 量化评分 */        [0, 0, 0, 0, 0],
      /* POC/Spike */       [0, 0, 0, 0, 0],
      /* ADR 决策记录 */    [0, 0, 2, 0, 0],
      /* 团队评审与共识 */  [0, 0, 0, 0, 1],
      /* 持续追踪与演进 */  [0, 0, 0, 0, 0]
    ];

    var option = {
      animation: false,
      tooltip: {
        trigger: 'item',
        formatter: function(p) {
          return '<strong>' + p.name + '</strong> x ' + cols[p.value[1]]
            + '<br/>覆盖度：' + heatLabel(p.value[2]);
        }
      },
      grid: { top: 20, bottom: 60, left: 160, right: 40 },
      xAxis: {
        type: 'category',
        data: cols,
        splitArea: { show: true },
        axisLabel: axisLabelStyle,
        axisLine: { lineStyle: { color: rule } },
        axisTick: { lineStyle: { color: rule } }
      },
      yAxis: {
        type: 'category',
        data: rows,
        splitArea: { show: true },
        axisLabel: axisLabelStyle,
        axisLine: { lineStyle: { color: rule } },
        axisTick: { lineStyle: { color: rule } }
      },
      visualMap: makeVisualMap(),
      series: [{
        name: '覆盖度',
        type: 'heatmap',
        data: data,
        label: {
          show: true,
          fontSize: 12,
          fontFamily: "'InstrumentSans', sans-serif",
          color: ink,
          formatter: function(p) { return heatLabel(p.value[2]); }
        },
        itemStyle: { borderColor: '#fff', borderWidth: 2, borderRadius: 4 }
      }]
    };

    chart.setOption(option);
    window.addEventListener('resize', function() { chart.resize(); });
  }

  /* ── Chart 2: dimension-heatmap ── */
  function initDimensionHeatmap() {
    var el = document.getElementById('dimension-heatmap');
    if (!el) return;
    var chart = echarts.init(el, null, { renderer: 'svg' });

    var rows = [
      '性能',
      '可扩展性',
      '成本',
      '社区生态',
      '易用性',
      '安全性',
      '团队能力匹配',
      '技术债务风险'
    ];
    var cols = ['TW 雷达', 'ADR', 'RFC', '评分矩阵', 'POC', 'DevFlow 现状'];

    var data = [
      /* 性能 */         [1, 1, 1, 2, 2, 0],
      /* 可扩展性 */     [1, 1, 1, 2, 2, 0],
      /* 成本 */         [0, 1, 0, 2, 1, 0],
      /* 社区生态 */     [2, 1, 0, 2, 0, 0],
      /* 易用性 */       [1, 0, 1, 2, 2, 0],
      /* 安全性 */       [1, 1, 0, 2, 1, 0],
      /* 团队能力匹配 */ [0, 1, 1, 2, 1, 0],
      /* 技术债务风险 */ [1, 1, 1, 2, 1, 0]
    ];

    var option = {
      animation: false,
      tooltip: {
        trigger: 'item',
        formatter: function(p) {
          return '<strong>' + p.name + '</strong> x ' + cols[p.value[1]]
            + '<br/>覆盖度：' + heatLabel(p.value[2]);
        }
      },
      grid: { top: 20, bottom: 60, left: 120, right: 40 },
      xAxis: {
        type: 'category',
        data: cols,
        splitArea: { show: true },
        axisLabel: axisLabelStyle,
        axisLine: { lineStyle: { color: rule } },
        axisTick: { lineStyle: { color: rule } }
      },
      yAxis: {
        type: 'category',
        data: rows,
        splitArea: { show: true },
        axisLabel: axisLabelStyle,
        axisLine: { lineStyle: { color: rule } },
        axisTick: { lineStyle: { color: rule } }
      },
      visualMap: makeVisualMap(),
      series: [{
        name: '覆盖度',
        type: 'heatmap',
        data: data,
        label: {
          show: true,
          fontSize: 12,
          fontFamily: "'InstrumentSans', sans-serif",
          color: ink,
          formatter: function(p) { return heatLabel(p.value[2]); }
        },
        itemStyle: { borderColor: '#fff', borderWidth: 2, borderRadius: 4 }
      }]
    };

    chart.setOption(option);
    window.addEventListener('resize', function() { chart.resize(); });
  }

  /* ── Initialize all charts on DOMContentLoaded ── */
  document.addEventListener('DOMContentLoaded', function() {
    initCoverageHeatmap();
    initDimensionHeatmap();
  });
})();
