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
    const contractAddress = "TU_DIRECCION_DE_CONTRATO_AQUI";

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
};