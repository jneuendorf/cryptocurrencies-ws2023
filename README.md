Grundidee

Wir wollen zwei Contracts bauen, einen NFT Contract (ERC721) und einen Coin Contract (ERC20).
NFT

Das NFT soll dazu da sein, als ein Zertifikat zu dienen, mit welchem man mit dem ERC20 Contract kommunizieren kann, um Tokens zu erhalten. Diese Tokens könnten dann zum Beispiel zum Voten in einem dezentralen System genutzt werden, oder einfach als Währung. Wir haben uns für das erste entschieden und die Implementierungsdetails werden im Abschnitt "Coin" erklärt.

Für die NFTs gelten folgende Bedingungen:

    Jedes NFT entspricht einer bestimmten Stufe, wodurch dann festgelegt wird, wie viele Coins man minten kann
    Jede Stufe entspricht einem Votingtoken, den man dafür bekommen kann, außer man erhält es als Beförderung
    Es gibt einen tag, welcher sagt, ob jemand ein NFT als Beförderung oder mint bekommen hat -- Ein NFT, welches man durch Beförderung erhalten hat, gibt einem nur das Recht auf nur einen (zusätzlichen) Token

ERC20 Token Design (FuVoteToken)

	Die decimal number ist 0, es gibt nur ganze Tokens
	Jeder, der ein NFT besitzt, sollte tokens minten können -- Jedes NFT sollte nur einmal minten können (mapping(tokenId => bool) minted)
	Beim minten: Update-NFTs geben nur einen Token, andere abhängig vom Level(n + 1)
	Lock Funktion oder nur Contract Owner darf Tokens umverteilen oder man transferiert Tokens bei Poll
	Mit transferOwnership(address_to) können wir den ownership von einer andresse zur einer anderen übertragen. Dies kann nur der contractOwner tun

ERC721 (FuNFT)
	Wenn wir minten, dann soll auch angegeben werden ob es upgradebar ist. (Stufe)
    
Voting
	1. startPoll() mit nur "Yes" und "No" als Optionen . Hierbei wird nur die Frage als string eingetragen. bool für multipleOptions is schon auf false gestellt als auch die Optionen nur auf "Yes" und "No" limitiert
    2. startPoll() mit mehreren Optionen. bool ob mehrere optionen erstellt werden können. Desweiteren können selbst Option erstellt werden
    castVote wird genutzt im zu Voten mit der Vorraussetzung, dass genügend Tokens vorhanden sind, um die gewünschte Gewichtsstufe errreicht wird.
	desweiteren muss der zu Wählende akzeptieren, dass die Coins auf das Konto des Contract owners transferiert
    endPoll, returnCoinsAfterPoll und getStatus macht genau das, was die Funktion sagt.
    getResults iteriert durch die Votes und zählt zusammen die Stimmen für jede einzelne Option
    formattedResults 
	

Schwierigkeiten:

    Inter-Contract-Kommunikation

Spezielle Eigenschaften

    Sollte jeder transferieren können?


Projektverlauf:

	- 17.01 Erstes Meeting: Aufsetzen der Metamask Wallet und Festlegen des Görli Testnetzwerk
	- 18.01 remix.ethereum.org als Coding Environment
	- 23.01 Github erstellt
		- Erste Ideen, Je höher eine Person gestellt ist desto mehr Votingrecht. 
		  Wallet balance dient als Indikator wie viel Voting stimmen jemand hat
		  Für jede Beförderungsstufe gibt es ein anderes NFT zum minten von Votingtokens
		  
	- 25.01 Arbeiten mit OpenZeppeline
	- 27.01 Zweites Meeting OpenZeppeline angeschaut über den ERC721 Contract
	- 30.01 Drittes meeting Code gearbeitet
	- 09.02 Tests schreiben
