# Frank N Furter

![FrankNFurter](https://github.com/anthonyshull/franknfurter/actions/workflows/static.yml/badge.svg)
![FrankNFurter](https://github.com/anthonyshull/franknfurter/actions/workflows/tests_docs.yml/badge.svg)

Frank N Furter is a currency conversion application with a [Rails](https://rubyonrails.org/) backend and [Alpine.js](https://alpinejs.dev/) frontend.

View the [generated documentation](https://anthonyshull.github.io/franknfurter/).

Backend [test coverage](https://anthonyshull.github.io/franknfurter/coverage) is set to a minimum of 99%. 

Static analysis, tests, and documentation generation are all run as [GitHub Actions](https://docs.github.com/en/actions).

## Application Structure

### API

Currencies are loaded into the database as seed data.

Frankenfurter only updates exchange rates once per day.
So, rather than requesting them with every conversion request, Frank N Furter runs a scheduled [job](https://guides.rubyonrails.org/active_job_basics.html) via [Solid Queue](https://github.com/rails/solid_queue) to update exchange rates at the top of every hour.

This makes conversions run quickly as they only require a database query rather than a network hop for the latest exchange rate.

Furthermore, exchange rates are stored with currencies ordered alphabetically.
This means that we don't store USD -> MXN as it's just the inversion of MXN -> USD.
It saves on storage as well as lookup time.

Lastly, the conversions service caches exchange rate lookups in memory for one hour so that database lookups are often unnecessary.

### UI

Frank N Furter bypasses Rails asset management completely and uses [Vite](https://vite.dev/) to bundle a very simple SPA.

Currencies are loaded from the API when the UI is initialized.
You can't select a target currency until you have selected a source currency.
Once you've selected a source currency, that currency is removed from the target currency list.
If you change the source currency after selecting one, you must reselect a target currency.
This helps to ensure that you must select two currencies that cannot be the same currency.

You cannot submit the form unless all fields have values.

Conversions appear below the form.
Once you submit the form, your conversion will appear at the top of the recent conversions list and will be highlighted.

## Usage

You should have [Docker](https://docs.docker.com/), [git](https://git-scm.com/doc), and [Make](https://www.gnu.org/software/make/manual/make.html) installed.

```shell
%> make setup
```

This will set up all services in the docker-compose.yml as well as prepare the database.

```shell
%> make up
```

You can now visit http://localhost:3001.

## Future Work

The exchange rates job currently emits N HTTP requests--one for every currency in the currencies table.
This can't be avoided as there is no way in the API to get a cartesian product of currencies and exchange rates.
However, we could have that job fan out by kicking of N jobs where each one handles just one HTTP request.