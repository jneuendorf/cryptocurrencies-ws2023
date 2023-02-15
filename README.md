# cryptocurrencies-ws2023

## Grundidee

Wir wollen zwei Contracts bauen, einen NFT Contract (ERC721) und einen Coin Contract (ERC20).



## NFT

Das NFT soll dazu da sein, als ein Zertifikat zu dienen, mit welchem man mit dem ERC20 Contract kommunizieren kann, um Tokens zu erhalten.
Diese Tokens könnten dann zum Beispiel zum Voten in einem dezentralen System genutzt werden, oder einfach als Währung.
Wir haben uns für das erste entschieden.

Für die NFTs gelten folgende Bedingungen:

- Jedes NFT entspricht einer bestimmten Stufe, wodurch dann festgelegt wird, wie viele Coins man minten kann
- Jede Stufe entspricht einem Votingtoken, den man dafür bekommen kann, außer man erhält es als Beförderung
- Es gibt einen tag, welcher sagt, ob jemand ein NFT als Beförderung oder mint bekommen hat
  - Ein NFT, welches man durch Beförderung erhalten hat, gibt einem nur das Recht auf nur einen (zusätzlichen) Token



## ERC20 Token Design (`FuVoteToken`)

- Die decimal number ist 0, es gibt nur ganze Tokens
- Jeder, der ein NFT besitzt, sollte tokens minten können -- Jedes NFT sollte nur einmal minten können (mapping(tokenId => bool) minted)
- Beim minten: Update-NFTs geben nur einen Token, andere abhängig vom Level



## ERC721 (`FuNFT`)

- Wenn wir minten, dann soll auch angegeben werden, ob es upgradebar ist. (Stufe)



## Voting

- `startPoll()` mit nur "Yes" und "No" als Optionen.
   Hierbei wird nur die Frage als string eingetragen. bool für `multipleOptions` ist schon auf false gestellt als auch die Optionen nur auf "Yes" und "No" limitiert.
- `startPoll()` mit mehreren Optionen. bool ob mehrere optionen erstellt werden können. Desweiteren können selbst Option erstellt werden
- `castVote` wird genutzt, um zu Voten. Vorraussetzung ist, dass genügend Tokens vorhanden sind, um die gewünschten Stimmen für die Wahl zu nutzen. Des Weiteren muss der Wählende akzeptieren, dass die Coins auf das Konto des Contract owners transferiert werden.
- `endPoll`, `returnCoinsAfterPoll` und `getStatus` macht genau das, was die Funktion sagt.
- `getResults` iteriert durch die Votes und zählt zusammen die Stimmen für jede einzelne Option
- `formattedResults`



## Limitierungen

- Der Contract owner darf nicht voten, weil er unendlich viele Stimmen hätte, dadurch dass die Voting tokens zu seiner Adresse gesendet werden und nach dem Poll wieder zurück
  - das sollte optimiert werden in einem realen Smart Contract
- Vor jedem Voten und beim Zurückschicken müssen die Votenden bzw. der owner dem Voting-contract die Berechtigung geben, die tokens zu versenden. Das macht man über increase allowance mit der Adresse des Voting-contracts und der Anzahl der Tokens. Tokenanzahl kann aber höher als aktuelle balance gewählt werden, um spätere Funktionsaufrufe und damit verbundene Kosten zu vermeiden
  - Das liegt daran, dass bei einem Funktionsaufruf eines contracts nicht der ursprüngliche Aufrufer bei dem Funktionsaufruf als msg.sender auftaucht, sondern die contract-Adresse, die diesen Funktionsaufruf getätigt hat



## Projektverlauf:

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
- 12.02 Vorstellung
