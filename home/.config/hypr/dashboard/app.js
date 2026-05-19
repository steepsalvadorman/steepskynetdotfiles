// ── Hyprland Dashboard Lógica de Interactividad ──

const API_BASE = 'http://127.0.0.1:8000';

// 1. Reloj en tiempo real
function updateClock() {
    const clockEl = document.getElementById('clock');
    const now = new Date();
    clockEl.textContent = now.toLocaleTimeString('es-ES', {
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
    });
}
setInterval(updateClock, 1000);
updateClock();

// 2. Controladores de sistema (Volumen, Brillo, Wallpaper)
async function controlSys(endpoint) {
    try {
        await fetch(`${API_BASE}/${endpoint}`);
    } catch (err) {
        console.error('Error enviando comando al sistema:', err);
    }
}

// 3. Monitoreo de Recursos en Tiempo Real
async function updateStats() {
    try {
        const res = await fetch(`${API_BASE}/sys`);
        if (!res.ok) return;
        const data = await res.json();

        // CPU Ring
        document.getElementById('cpu-val').textContent = `${data.cpu}%`;
        document.getElementById('cpu-fill').setAttribute('stroke-dasharray', `${data.cpu}, 100`);

        // RAM Ring
        document.getElementById('ram-val').textContent = `${data.ram}%`;
        document.getElementById('ram-fill').setAttribute('stroke-dasharray', `${data.ram}, 100`);

        // Temp Ring
        // Mapear temp de 0 a 100 grados para la visualización del aro
        const tempPct = Math.min(Math.max(data.temp, 0), 100);
        document.getElementById('temp-val').textContent = `${data.temp}°C`;
        document.getElementById('temp-fill').setAttribute('stroke-dasharray', `${tempPct}, 100`);
    } catch (err) {
        console.warn('Backend server.py no está respondiendo a monitoreo de recursos.');
    }
}
setInterval(updateStats, 1000);
updateStats();

// 4. Reproductor Lo-Fi
const audio = document.getElementById('lofi-audio');
const playBtn = document.getElementById('play-pause-btn');
const channelSelect = document.getElementById('channel-select');
const stationTitle = document.getElementById('station-title');
const lofiGif = document.querySelector('.lofi-gif');

playBtn.addEventListener('click', () => {
    if (audio.paused) {
        audio.play().then(() => {
            playBtn.textContent = '⏸ PAUSAR MÚSICA';
            playBtn.classList.add('playing');
            lofiGif.style.filter = 'none'; // Activar animación visual
        }).catch(err => {
            console.error('Error de reproducción de audio:', err);
        });
    } else {
        audio.pause();
        playBtn.textContent = '▶ REPRODUCIR';
        playBtn.classList.remove('playing');
        lofiGif.style.filter = 'grayscale(80%)';
    }
});

channelSelect.addEventListener('change', () => {
    const isPlaying = !audio.paused;
    audio.src = channelSelect.value;
    stationTitle.textContent = channelSelect.options[channelSelect.selectedIndex].text.replace('📻 ', '');
    
    if (isPlaying) {
        audio.play().catch(err => console.error(err));
    }
});

// Inicializar gif de lofi pausado
lofiGif.style.filter = 'grayscale(80%)';

// 5. Buscador de Anime (Jikan API MyAnimeList)
const animeInput = document.getElementById('anime-input');
const searchBtn = document.getElementById('search-btn');
const resultsBox = document.getElementById('anime-results');
const detailsBox = document.getElementById('anime-details');

const detailImg = document.getElementById('detail-img');
const detailTitle = document.getElementById('detail-title');
const detailSynopsis = document.getElementById('detail-synopsis');
const playAnimeBtn = document.getElementById('play-anime-btn');

async function searchAnime() {
    const query = animeInput.value.trim();
    if (!query) return;

    resultsBox.innerHTML = '<div class="search-placeholder">Buscando en MyAnimeList...</div>';
    detailsBox.style.display = 'none';

    try {
        const res = await fetch(`https://api.jikan.moe/v4/anime?q=${encodeURIComponent(query)}&limit=6`);
        if (!res.ok) throw new Error('API limit/error');
        const json = await res.json();
        const results = json.data || [];

        if (results.length === 0) {
            resultsBox.innerHTML = '<div class="search-placeholder">No se encontraron resultados.</div>';
            return;
        }

        resultsBox.innerHTML = '';
        results.forEach(anime => {
            const card = document.createElement('div');
            card.className = 'anime-card';
            card.innerHTML = `
                <img src="${anime.images.jpg.image_url}" alt="${anime.title}">
                <div class="anime-card-title">${anime.title}</div>
            `;
            card.addEventListener('click', () => {
                // Quitar selección previa
                document.querySelectorAll('.anime-card').forEach(c => c.classList.remove('selected'));
                card.classList.add('selected');
                showAnimeDetails(anime);
            });
            resultsBox.appendChild(card);
        });

    } catch (err) {
        resultsBox.innerHTML = '<div class="search-placeholder">Error al buscar anime. Inténtalo de nuevo.</div>';
        console.error(err);
    }
}

function showAnimeDetails(anime) {
    detailsBox.style.display = 'flex';
    detailImg.style.display = 'block';
    detailImg.src = anime.images.jpg.large_image_url || anime.images.jpg.image_url;
    detailTitle.textContent = anime.title;
    detailSynopsis.textContent = anime.synopsis || 'Sin sinopsis disponible.';

    // Configurar el botón de reproducción con MPV
    // Si tiene trailer en youtube, enviamos el trailer a MPV. De lo contrario, enviamos la página de MAL.
    const streamUrl = anime.trailer?.url || anime.url;
    playAnimeBtn.style.display = 'block';
    
    // Remover event listeners anteriores clonando el botón
    const newPlayBtn = playAnimeBtn.cloneNode(true);
    playAnimeBtn.replaceWith(newPlayBtn);
    
    newPlayBtn.addEventListener('click', () => {
        controlSys(`anime/play?url=${encodeURIComponent(streamUrl)}`);
    });
}

searchBtn.addEventListener('click', searchAnime);
animeInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') searchAnime();
});

// 6. Botón Cerrar Window
document.getElementById('close-btn').addEventListener('click', () => {
    window.close();
});

// Permitir cerrar pulsando Escape
window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        window.close();
    }
});
