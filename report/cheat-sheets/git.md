# Git Cheat Sheet

## Basisconfigratie

### Informatie
De lokale repository bestaat uit drie verschillende 'trees' beheerd door git:
- `Working Directory`: bevat bestanden
- `Index`: gedraagt zich als tussenstadium
- `Head`: verwijst naar de laatst gemaakte commit

### Git instellingen
```
$ git config --global user.name "VOORNAAM NAAM"
$ git config --global user.email "VOORNAAM.NAAM@EXAMPLE.COM"
$ git config --global push.default simple
$ git config --global core.autocrlf input
```
### Repository clonen
```
$ cd Documents/Courses/EnterpriseLinux/
$ git clone git@github.com:HoGentTIN/REPONAAM-GEBRUIKERSNAAM.git repo
```

### Nieuwe branch aanmaken voor eigen code en documentatie
```
$ git checkout -b solution
```

### Nieuwe updates in de opdracht binnenhalen
```
$ git checkout master      
$ git pull upstream master
$ git checkout solution
$ git rebase master
```
### Bestanden toevoegen aan de centrale repository
| Commando      | Betekenis       |
| ------------- |:-------------|
| `git add <bestandnaam>`| aanpassingen aan de files toevoegen in de index | 
| `git add *` | voegt alle bestanden toe aan de index |
| `git commit -m "Commit message"` | aanpassingen echt doorvoeren (naar HEAD) |
| `git push origin master`| aanpassingen pushen naar de repository |

### Branching uitgelegd
<dl>
  <dt>Master branch</dt>
  <dd>Standaard branch bij een nieuwe repository</dd>
</dl>

- Maak nieuwe branches aan wanneer je nieuwe toevoegingen wilt ontwikkelen en voeg ze samen (merge) met de master wanneer je klaar bent.

| Commando      | Betekenis       |
| ------------- |:-------------|
| `git checkout -b feature_X`| maak een nieuwe branch aan en ga er onmiddelijk naartoe |
| `git checkout master` | ga terug naar de master branch |
| `git branch -d feature_X` | verwijder de branch |
| `git push origin <branch>`| een branch is niet beschikbaar voor anderen tenzij je ze synchroniseert met de centrale repository |

### Update & merge

| Commando      | Betekenis       |
| ------------- |:-------------|
| `git pull`| lokale repository updaten naar de laatste versie |
| `git merge <branch>` | andere branch samenvoegen met de actievve branch |
| `git branch -d feature_X` | verwijder de branch |