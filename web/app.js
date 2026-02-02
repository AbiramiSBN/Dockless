function copyText(id){
  const el = document.getElementById(id);
  const text = el.innerText.trim();
  navigator.clipboard.writeText(text).then(()=>{
    const btn = el.closest('.codebox').querySelector('button');
    if(!btn) return;
    const old = btn.innerHTML;
    btn.innerHTML = 'Copied ✓';
    setTimeout(()=>btn.innerHTML = old, 1200);
  });
}

// Smooth anchor scrolling
document.querySelectorAll('a[href^="#"]').forEach(a=>{
  a.addEventListener('click', e=>{
    const target = document.querySelector(a.getAttribute('href'));
    if(!target) return;
    e.preventDefault();
    target.scrollIntoView({behavior:'smooth', block:'start'});
  });
});
