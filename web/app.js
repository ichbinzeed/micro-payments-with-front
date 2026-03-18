const signBtn = document.getElementById('signBtn');
const connectBtn = document.getElementById('connectWallet');

let provider, signer;

// Conectar a MetaMask
connectBtn.onclick = async () => {
    provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    signer = provider.getSigner();
    alert("Billetera conectada: " + await signer.getAddress());
};

signBtn.onclick = async () => {
    const recipient = document.getElementById('recipient').value;
    const amount = ethers.utils.parseEther(document.getElementById('amount').value);
    const nonce = document.getElementById('nonce').value;
    const contractAddress = "0x2EfdC9e38bEAF93BEC3BE5f172127D580337CBc5";

    // 1. Crear el Hash (lo mismo que haria Solidity con abi.encodePacked)
    const hash = ethers.utils.solidityKeccak256(
        ["address", "uint256", "uint256", "address"],
        [recipient, amount, nonce, contractAddress]
    );

    try {
        // 2. Firmar el hash
        // Esto abrirá MetaMask para que Alice firme
        const signature = await signer.signMessage(ethers.utils.arrayify(hash));

        document.getElementById('signatureResult').value = signature;
        console.log("Firma generada:", signature);
    } catch (err) {
        console.error("Error al firmar:", err);
    }

    async function safeSign() {
        try {
            // 1. Verificamos si tenemos cuentas, si no, pedimos conexión
            const accounts = await window.ethereum.request({ method: 'eth_accounts' });
            if (accounts.length === 0) {
                await window.ethereum.request({ method: 'eth_requestAccounts' });
            }

            // 2. Ahora sí lanzamos la firma
            const signature = await signer.signMessage(ethers.utils.arrayify(messageHash));
            console.log("Firma generada:", signature);

        } catch (err) {
            if (err.code === 4001) {
                console.log("El usuario rechazó la firma.");
            } else {
                console.error("Error inesperado:", err);
            }
        }
    }
};