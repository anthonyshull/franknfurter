import Alpine from 'alpinejs'

window.Alpine = Alpine

window.currencyForm = function() {
	return {
		currencies: [],
		conversions: [],
		source: '',
		target: '',
		amount: '',
		error: null,
		latestConversionId: null,
		get filteredTargets() {
			return this.currencies.filter(code => code !== this.source)
		},
		formatDate(dateString) {
			const date = new Date(dateString)
			const weekday = date.toLocaleDateString('en-US', { weekday: 'short' })
			const month = date.toLocaleDateString('en-US', { month: 'short' })
			const day = date.getDate()
			const suffix = ['th', 'st', 'nd', 'rd'][(day % 10 > 3 || Math.floor(day % 100 / 10) === 1) ? 0 : day % 10]
			const time = date.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true })
			return `${weekday}, ${month} ${day}${suffix} ${time}`
		},
		async fetchCurrencies() {
			const apiUrl = import.meta.env.VITE_API_URL || "http://localhost:3000"
			try {
				const response = await fetch(`${apiUrl}/currencies`)
				if (!response.ok) throw new Error("Failed to fetch currencies")
				this.currencies = await response.json()
			} catch (e) {
				this.currencies = []
			}
			await this.fetchConversions()
		},
		async fetchConversions() {
			const apiUrl = import.meta.env.VITE_API_URL || "http://localhost:3000"
			try {
				const response = await fetch(`${apiUrl}/conversions`)
			    this.conversions = await response.json()
			} catch (e) {
				this.conversions = []
			}
		},
        resetTarget() {
            this.target = ''
        },
        async submitConversion() {
            const apiUrl = import.meta.env.VITE_API_URL || "http://localhost:3000"
            try {
                this.error = null
                const payload = {
                    source_currency_code: this.source,
                    target_currency_code: this.target,
                    source_amount: this.amount
                }
                const response = await fetch(`${apiUrl}/convert`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify(payload)
                })
                if (!response.ok) {
                    const errorData = await response.json()
                    throw new Error(errorData.error || "Conversion failed")
                }
                const result = await response.json()
                this.latestConversionId = result.id
                // Optionally show result, then reload conversions
                await this.fetchConversions()
                this.amount = ''
                this.source = ''
                this.target = ''
            } catch (e) {
                this.error = e.message
            }
        }
	}
}

Alpine.start()
