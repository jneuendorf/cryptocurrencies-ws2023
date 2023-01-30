# cryptocurrencies-ws2023

## Grundidee

Wir wollen zwei Contracts bauen, einen NFT Contract (ERC721) und einen Coin Contract (ERC20).

### NFT

Das NFT soll dazu da sein, als ein Zertifikat zu dienen, mit welchem man mit dem ERC20 Contract kommunizieren kann, um Tokens zu erhalten. Diese Tokens könnten dann zum Beispiel zum Voten in einem dezentralen System genutzt werden, oder einfach als Währung. Wir haben uns für das erste entschieden und die Implementierungsdetails werden im Abschnitt "Coin" erklärt.

Für die NFTs gelten folgende Bedingungen:
- Jedes NFT entspricht einer bestimmten Stufe, wodurch dann festgelegt wird, wie viele Coins man minten kann
- Jede Stufe entspricht einem Votingtoken, den man dafür bekommen kann, außer man erhält es als Beförderung
- Es gibt einen tag, welcher sagt, ob jemand ein NFT als Beförderung oder mint bekommen hat
-- Ein NFT, welches man durch Beförderung erhalten hat, gibt einem nur das Recht auf nur einen (zusätzlichen) Token


Phasen:
Teil 1: Aufsetzen des ERC721 Vertrags inklusive Logik, wie wir beim ursprünglichen Mint vorgehen - wie kommen die Mitarbeiter an ihre Zertifikate?
Teil 2: Aufsetzen ERC20 Vertrags und festlegen der Parameter wie Total Supply, Transferlogik etc.
Teil 3: Mintlogik beider Verträge ist fertig, sie sind miteinander verbunden
Teil 4: Weitere Dinge, die uns einfallen, implementieren: Wer darf wann auf welche Parameter im nachhinein zugreifen und sie verändern? Welche Sicherheitsaspekte muss man noch beachten? Wollen wir vielleicht doch noch einen dritten Smart Contract schreiben, weil das alles zu schnell ging?