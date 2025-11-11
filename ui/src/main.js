
import Alpine from 'alpinejs'

window.Alpine = Alpine


window.currencyForm = function() {
	return {
		currencies: [],
		source: '',
		target: '',
		amount: '',
		get filteredTargets() {
			return this.currencies.filter(code => code !== this.source)
		},
		async fetchCurrencies() {
			// TODO: Replace with actual API call to `${import.meta.env.VITE_API_URL}/currencies`
			// const response = await fetch(`${import.meta.env.VITE_API_URL}/currencies`)
			// this.currencies = await response.json()
			this.currencies = ["EUR", "USD"]
		},
		resetTarget() {
			this.target = ''
		}
	}
}

Alpine.start()
