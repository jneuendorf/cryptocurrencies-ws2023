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

### ERC20 Token Design (FuVoteToken)

- Die decimal number ist 0, es gibt nur ganze Tokens
- Jeder, der ein NFT besitzt, sollte tokens minten können
-- Jedes NFT sollte nur einmal minten können (mapping(tokenId => bool) minted)
- Beim minten: Update-NFTs geben nur einen Token, andere abhängig vom Level(n + 1)
- Lock Funktion oder nur Contract Owner darf Tokens umverteilen oder man transferiert Tokens bei Poll

Schwierigkeiten:
- Inter-Contract-Kommunikation

Spezielle Eigenschaften
- Sollte jeder transferieren können?