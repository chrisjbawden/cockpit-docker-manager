document.addEventListener("DOMContentLoaded", () => {
  const containerList = document.getElementById("container-list");
  const refreshButton = document.getElementById("refresh-button");

  if (!containerList || typeof cockpit === "undefined") return;

  function runDockerCommand(container, action) {
    cockpit.spawn(["docker", action, container], { err: "message" })
      .then(() => loadContainers());
  }

  window.runDockerCommand = runDockerCommand;

  function parsePorts(portText) {
    if (!portText) return "";

    const hostname = window.location.hostname;
    const seen = new Set();

    // Match patterns like "0.0.0.0:8080->80/tcp", "[::]:8443->443/tcp", etc.
    const matches = portText.match(/(?:[0-9.:\\[\\]]+)?:(\d+)->/g);
    if (!matches) return "";

    return matches.map(m => {
      const portMatch = m.match(/:(\d+)->/);
      if (!portMatch) return null;

      const hostPort = portMatch[1];
      if (seen.has(hostPort)) return null;
      seen.add(hostPort);

      return `<a href="http://${hostname}:${hostPort}" target="_blank">${hostPort}</a>`;
    }).filter(Boolean).join(" ");
  }

  function loadContainers() {
    containerList.innerHTML = `<div class="loading">Loading containers...</div>`;

    cockpit.spawn(["docker", "ps", "-a", "--format", "{{.Names}}\t{{.Status}}\t{{.Ports}}"], { err: "message" })
      .then(output => {
        const lines = output.trim().split("\n");
        if (!lines.length || !lines[0]) {
          containerList.innerHTML = `<div class="empty">No containers found.</div>`;
          return;
        }

        const cards = lines.map(line => {
          const [name, statusRaw = "", portsRaw = ""] = line.split("\t");
          const isRunning = statusRaw.toLowerCase().startsWith("up");
          const portsHTML = parsePorts(portsRaw);

          return `
            <div class="container-card ${isRunning ? "" : "stopped"}">
              <div class="container-info">
                <div class="container-name">${name}</div>
                <div class="container-status">${statusRaw}</div>
              </div>
              <div class="container-ports">${portsHTML}</div>
              <div class="container-actions">
                ${isRunning
                  ? `<button onclick="runDockerCommand('${name}', 'stop')">Stop</button>`
                  : `<button onclick="runDockerCommand('${name}', 'start')">Start</button>`}
                <button onclick="runDockerCommand('${name}', 'restart')">Restart</button>
              </div>
            </div>
          `;
        });

        containerList.innerHTML = cards.join("");
      })
      .catch(() => {
        containerList.innerHTML = `
          <div class="error">
            ❌ Cannot access Docker. Make sure this user is in the <code>docker</code> group.
          </div>`;
      });
  }

  refreshButton?.addEventListener("click", loadContainers);

  cockpit.spawn(["docker", "version"], { err: "message" })
    .then(() => {
      loadContainers();
      setInterval(loadContainers, 5 * 60 * 1000); // Auto refresh every 5 minutes
    })
    .catch(() => {
      containerList.innerHTML = `
        <div class="error">
          ❌ Docker is not accessible.<br>
          Ensure this user is in the <code>docker</code> group.
        </div>`;
    });
});
