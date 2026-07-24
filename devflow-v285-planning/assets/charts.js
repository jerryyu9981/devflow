(function() {
  var style = getComputedStyle(document.documentElement);
  var accent = style.getPropertyValue('--accent').trim();
  var accent2 = style.getPropertyValue('--accent2').trim();
  var ink = style.getPropertyValue('--ink').trim();
  var muted = style.getPropertyValue('--muted').trim();
  var rule = style.getPropertyValue('--rule').trim();
  var bg2 = style.getPropertyValue('--bg2').trim();
  var p0 = style.getPropertyValue('--p0').trim();
  var p1 = style.getPropertyValue('--p1').trim();
  var p2 = style.getPropertyValue('--p2').trim();

  // --- Chart: Priority Distribution (Pie) ---
  var chart1 = echarts.init(document.getElementById('chart-priority'), null, { renderer: 'svg' });
  chart1.setOption({
    tooltip: { trigger: 'item', appendToBody: true, formatter: '{b}: {c} 项 ({d}%)' },
    animation: false,
    series: [{
      type: 'pie',
      radius: ['42%', '70%'],
      center: ['50%', '50%'],
      avoidLabelOverlap: true,
      padAngle: 3,
      itemStyle: { borderRadius: 6, borderColor: bg2, borderWidth: 2 },
      label: { show: true, formatter: '{b}\n{c} 项', color: muted, fontSize: 12, fontWeight: 600 },
      emphasis: { label: { show: true, fontSize: 14, fontWeight: 'bold' } },
      data: [
        { value: 1, name: 'P0', itemStyle: { color: p0 } },
        { value: 6, name: 'P1', itemStyle: { color: p1 } },
        { value: 1, name: 'P2', itemStyle: { color: p2 } }
      ]
    }]
  });
  window.addEventListener('resize', function() { chart1.resize(); });

  // --- Chart: Debt Type Distribution (Bar) ---
  var chart2 = echarts.init(document.getElementById('chart-debt-type'), null, { renderer: 'svg' });
  chart2.setOption({
    tooltip: { trigger: 'axis', appendToBody: true, axisPointer: { type: 'shadow' } },
    animation: false,
    grid: { left: '3%', right: '4%', bottom: '8%', top: '6%', containLabel: true },
    xAxis: { type: 'value', axisLabel: { color: muted, fontSize: 11 }, splitLine: { lineStyle: { color: rule } } },
    yAxis: {
      type: 'category',
      data: ['流程债务', '文档债务', '质量债务'],
      axisLabel: { color: ink, fontSize: 12, fontWeight: 600 },
      axisLine: { show: false },
      axisTick: { show: false },
      splitLine: { show: false }
    },
    series: [{
      type: 'bar',
      data: [
        { value: 6, itemStyle: { color: accent, borderRadius: [0, 6, 6, 0] } },
        { value: 1, itemStyle: { color: accent2, borderRadius: [0, 6, 6, 0] } },
        { value: 1, itemStyle: { color: '#7c3aed', borderRadius: [0, 6, 6, 0] } }
      ],
      barWidth: '55%',
      label: {
        show: true,
        position: 'right',
        formatter: '{c} 条',
        color: muted,
        fontSize: 12,
        fontWeight: 600
      }
    }]
  });
  window.addEventListener('resize', function() { chart2.resize(); });

  // --- Chart: Global Debt Severity Distribution (Pie) ---
  var chart3 = echarts.init(document.getElementById('chart-debt-severity'), null, { renderer: 'svg' });
  chart3.setOption({
    tooltip: { trigger: 'item', appendToBody: true, formatter: '{b}: {c} 条 ({d}%)' },
    animation: false,
    series: [{
      type: 'pie',
      radius: ['45%', '72%'],
      center: ['50%', '50%'],
      avoidLabelOverlap: true,
      padAngle: 2,
      itemStyle: { borderRadius: 5, borderColor: bg2, borderWidth: 2 },
      label: { show: true, formatter: '{b}\n{c} 条', color: muted, fontSize: 12 },
      emphasis: { label: { show: true, fontSize: 14, fontWeight: 'bold' } },
      data: [
        { value: 3, name: 'P0', itemStyle: { color: p0 } },
        { value: 12, name: 'P1', itemStyle: { color: p1 } },
        { value: 5, name: 'P2', itemStyle: { color: p2 } }
      ]
    }]
  });
  window.addEventListener('resize', function() { chart3.resize(); });

})();
