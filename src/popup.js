// 初始化时区选择器
const timezones = moment.tz.names();
const timezoneSelect = document.getElementById('timezone');
const userTimezone = moment.tz.guess();

timezones.forEach(timezone => {
  const option = document.createElement('option');
  option.value = timezone;
  option.text = timezone;
  if (timezone === userTimezone) {
    option.selected = true;
  }
  timezoneSelect.appendChild(option);
});

// 更新当前时间显示
function updateCurrentTime() {
  const now = moment().tz(timezoneSelect.value);
  document.getElementById('currentTime').textContent = now.format('YYYY-MM-DD HH:mm:ss');
}
setInterval(updateCurrentTime, 1000);

// 复制功能
function copyToClipboard(text) {
  navigator.clipboard.writeText(text).then(() => {
    // 可以添加复制成功的提示
  });
}

document.getElementById('copyCurrentTime').addEventListener('click', () => {
  copyToClipboard(document.getElementById('currentTime').textContent);
});

document.getElementById('copyTimestampResult').addEventListener('click', () => {
  copyToClipboard(document.getElementById('timestampResult').textContent);
});

document.getElementById('copyDateResult').addEventListener('click', () => {
  copyToClipboard(document.getElementById('dateResult').textContent);
});

// 历史记录功能
let history = JSON.parse(localStorage.getItem('conversionHistory') || '[]');

function addToHistory(input, output, type) {
  history.unshift({ input, output, type, timestamp: Date.now() });
  if (history.length > 10) history.pop();
  localStorage.setItem('conversionHistory', JSON.stringify(history));
  updateHistoryDisplay();
}

function updateHistoryDisplay() {
  const historyList = document.getElementById('historyList');
  historyList.innerHTML = '';
  history.forEach(item => {
    const div = document.createElement('div');
    div.className = 'history-item';
    div.textContent = `${item.input} → ${item.output}`;
    historyList.appendChild(div);
  });
}

document.getElementById('clearHistory').addEventListener('click', () => {
  history = [];
  localStorage.setItem('conversionHistory', '[]');
  updateHistoryDisplay();
});

// 时间戳转换功能
document.getElementById('convertTimestampButton').addEventListener('click', function() {
  const timestamp = document.getElementById('timestampInput').value;
  const selectedTimezone = timezoneSelect.value;
  
  try {
    const date = moment(parseInt(timestamp)).tz(selectedTimezone);
    if (date.isValid()) {
      const result = date.format('YYYY-MM-DD HH:mm:ss');
      document.getElementById('timestampResult').textContent = result;
      
      // 显示相对时间
      const relativeTime = date.fromNow();
      document.getElementById('relativeTime').textContent = relativeTime;
      
      addToHistory(timestamp, result, 'timestamp-to-date');
    } else {
      document.getElementById('timestampResult').textContent = 'Invalid timestamp';
      document.getElementById('relativeTime').textContent = '';
    }
  } catch (e) {
    document.getElementById('timestampResult').textContent = 'Invalid input';
    document.getElementById('relativeTime').textContent = '';
  }
});

// 日期转时间戳功能
document.getElementById('convertDateButton').addEventListener('click', function() {
  const dateString = document.getElementById('dateInput').value;
  const selectedTimezone = timezoneSelect.value;
  
  try {
    const date = moment.tz(dateString, selectedTimezone);
    if (date.isValid()) {
      const timestamp = date.valueOf().toString();
      document.getElementById('dateResult').textContent = timestamp;
      addToHistory(dateString, timestamp, 'date-to-timestamp');
    } else {
      document.getElementById('dateResult').textContent = 'Invalid date format';
    }
  } catch (e) {
    document.getElementById('dateResult').textContent = 'Invalid input';
  }
});

// 日期计算功能
document.getElementById('calculateDiff').addEventListener('click', function() {
  const date1String = document.getElementById('date1').value;
  const date2String = document.getElementById('date2').value;
  const selectedTimezone = timezoneSelect.value;
  
  try {
    const date1 = moment.tz(date1String, selectedTimezone);
    const date2 = moment.tz(date2String, selectedTimezone);
    
    if (date1.isValid() && date2.isValid()) {
      const diff = moment.duration(date2.diff(date1));
      const result = `${diff.years()}年 ${diff.months()}月 ${diff.days()}天 ${diff.hours()}小时 ${diff.minutes()}分钟 ${diff.seconds()}秒`;
      document.getElementById('dateDiffResult').textContent = result;
    } else {
      document.getElementById('dateDiffResult').textContent = 'Invalid date format';
    }
  } catch (e) {
    document.getElementById('dateDiffResult').textContent = 'Invalid input';
  }
});

// 初始化显示
updateCurrentTime();
updateHistoryDisplay();
  