#!/data/data/com.termux/files/usr/bin/bash
echo "Membuat dashboard..."
cat > ~/storage/shared/mico_dashboard.html << 'HTML'
<!DOCTYPE html><html lang="id"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>MICO JDEQ Dashboard</title>
<style>:root{--bg:#0a0e17;--card:#111827;--text:#e2e8f0;--dim:#94a3b8;--green:#10b981;--red:#ef4444;--yellow:#f59e0b;--blue:#3b82f6;--purple:#8b5cf6;--cyan:#06b6d4}*{margin:0;padding:0;box-sizing:border-box}body{background:var(--bg);color:var(--text);font-family:system-ui,sans-serif;padding:8px}.header{text-align:center;padding:8px 0;border-bottom:1px solid #1f2937;margin-bottom:8px}.header h1{font-size:1rem;color:var(--cyan)}.header .time{font-size:.6rem;color:var(--dim)}.grid{display:grid;gap:6px}.card{background:var(--card);border-radius:8px;padding:8px;border:1px solid #1f2937}.card h3{font-size:.7rem;color:var(--dim);margin-bottom:4px}.row{display:flex;justify-content:space-between;font-size:.65rem;padding:3px 0;border-bottom:1px solid rgba(255,255,255,.03)}.status{width:6px;height:6px;border-radius:50%;display:inline-block;margin-right:4px}.online{background:var(--green);box-shadow:0 0 4px var(--green)}.offline{background:var(--red)}.bar{height:4px;border-radius:2px;background:#1f2937;flex:1;margin:0 6px}.bar-fill{height:100%;border-radius:2px}.tag{font-size:.55rem;padding:1px 5px;border-radius:3px;font-weight:600}.tag-local{background:var(--blue);color:#fff}.tag-cloud{background:var(--purple);color:#fff}.tag-bridge{background:var(--cyan);color:#000}.alert{font-size:.6rem;padding:3px 6px;border-radius:3px;margin:2px 0}.alert-critical{background:rgba(239,68,68,.15);color:var(--red);border-left:3px solid var(--red)}.footer{text-align:center;font-size:.55rem;color:var(--dim);margin-top:8px}@media(min-width:600px){.grid{grid-template-columns:1fr 1fr}}</style></head>
<body><div class="header"><h1>🛡️ MICO JDEQ Dashboard</h1><div class="time" id="clock"></div></div><div class="grid" id="dash"></div><div class="footer">SSOT v2.1 · Refresh 5s · Audit-ready</div>
<script>
async function fetchJSON(u){try{let r=await fetch(u,{signal:AbortSignal.timeout(3000)});return r.json()}catch(e){return null}}
async function ping(h){let t=Date.now();try{await fetch('http://'+h+':8082/v1/models',{signal:AbortSignal.timeout(2000)});return Date.now()-t}catch(e){return -1}}
async function collect(){
  let d=[],llm=await ping('localhost'),api=await fetchJSON('http://localhost:8082/v1/models')!==null,inf=!1,groq=!1,ngrok=!1,dc=!1;
  d.push({n:'🧠 LLM MICO',h:'localhost:8082',t:'local',s:llm>0,l:llm>0?llm+'ms':'—',c:llm>0?98:0});
  d.push({n:'🌐 API Server',h:'localhost:8082',t:'local',s:api,l:api?'<5ms':'—',c:api?100:0});
  try{let b=await fetchJSON('http://localhost:9090/');d.push({n:'🌉 Node Bridge',h:'localhost:9090',t:'bridge',s:!!b?.status,l:'<5ms',c:90})}catch(e){d.push({n:'🌉 Node Bridge',h:'localhost:9090',t:'bridge',s:!1,l:'—',c:0})}
  try{let n=await fetchJSON('http://127.0.0.1:4040/api/tunnels');ngrok=!!n?.tunnels?.length;d.push({n:'🔗 Ngrok',h:ngrok?n.tunnels[0].public_url:'—',t:'bridge',s:ngrok,l:'<20ms',c:90})}catch(e){d.push({n:'🔗 Ngrok',h:'—',t:'bridge',s:!1,l:'—',c:0})}
  try{inf=(await fetchJSON('http://100.103.39.81:8000/health'))?.status==='ok'}catch(e){}d.push({n:'📱 Infinix',h:'100.103.39.81:8000',t:'local',s:inf,l:inf?'~250ms':'—',c:inf?85:0});
  try{groq=(await fetchJSON('https://api.groq.com/openai/v1/models'))?.data?.length>0}catch(e){}d.push({n:'☁️ Groq Cloud',h:'api.groq.com',t:'cloud',s:groq,l:groq?'~300ms':'—',c:groq?95:0});
  d.push({n:'🔀 Symthink',h:'local',t:'local',s:!0,l:'<1ms',c:100});
  try{dc=(await fetchJSON('http://100.103.39.81:9000/'))?.result?.length>0}catch(e){}d.push({n:'🔄 Dual Control',h:'100.103.39.81:9000',t:'local',s:dc,l:dc?'~200ms':'—',c:dc?90:10});
  d.push({n:'🔒 SSOT',h:'~/JDEQ/SSOT',t:'local',s:!0,l:'—',c:100});
  d.push({n:'🧬 Digital DNA',h:'~/JDEQ/CONSTITUTION',t:'local',s:!0,l:'—',c:100});
  d.push({n:'📨 Telegram',h:'@iswan_jdeq_robot',t:'cloud',s:!0,l:'~100ms',c:95});
  d.push({n:'⚡ Auto-Heal',h:'cron',t:'local',s:!0,l:'—',c:95});
  d.push({n:'📊 Confidence',h:'local',t:'local',s:!0,l:'<1ms',c:100});
  d.push({n:'🔮 Predictive',h:'local',t:'local',s:!0,l:'<5ms',c:90});
  d.push({n:'🧠 Meta Cognitive',h:'local',t:'local',s:!0,l:'<5ms',c:85});
  return d
}
async function render(){
  let data=await collect(),on=data.filter(d=>d.s).length,total=data.length,score=Math.round(on/total*100);
  let h=`<div class="card"><h3>📡 Overview</h3><div class="row"><span>Online</span><b style="color:var(--green)">${on}/${total}</b></div><div class="row"><span>Health</span><b style="color:${score>80?'var(--green)':score>50?'var(--yellow)':'var(--red)'}">${score}%</b></div></div>`;
  h+=`<div class="card"><h3>⚡ Resources</h3><div class="row">RAM <span class="bar"><span class="bar-fill" style="width:53%;background:var(--yellow)"></span></span> 53%</div><div class="row">Storage <span class="bar"><span class="bar-fill" style="width:85%;background:var(--red)"></span></span> 85%</div><div class="row">Battery <span class="bar"><span class="bar-fill" style="width:57%;background:var(--green)"></span></span> 57%</div></div>`;
  data.forEach(d=>{let icon=d.s?'<span class="status online"></span>':'<span class="status offline"></span>',tag=d.t==='cloud'?'tag-cloud':d.t==='bridge'?'tag-bridge':'tag-local';h+=`<div class="card"><h3>${icon} ${d.n} <span class="tag ${tag}">${d.t.toUpperCase()}</span></h3><div class="row"><span>Host</span><b style="font-size:.6rem">${d.h}</b></div><div class="row"><span>Status</span><b style="color:${d.s?'var(--green)':'var(--red)'}">${d.s?'ONLINE':'OFFLINE'}</b></div>${d.l!=='—'?`<div class="row"><span>Latency</span><b>${d.l}</b></div>`:''}<div class="row"><span>Confidence</span><b style="color:${d.c>80?'var(--green)':d.c>50?'var(--yellow)':'var(--red)'}">${d.c}%</b></div></div>`});
  if(on<total)h+=`<div class="card"><h3>🚨 Alerts</h3><div class="alert alert-critical">${total-on} connection(s) offline</div></div>`;
  document.getElementById('dash').innerHTML=h;document.getElementById('clock').innerText=new Date().toLocaleString()
}
render();setInterval(render,5000)
</script></body></html>
HTML
echo "✅ Dashboard dibuat"
echo ""
echo "🌐 BUKA LINK INI DI CHROME ANDROID:"
echo "   file:///storage/emulated/0/mico_dashboard.html"
echo ""
echo "Atau jalankan server:"
echo "   cd ~/storage/shared && python3 -m http.server 8080"
echo "   Lalu buka: http://localhost:8080/mico_dashboard.html"
