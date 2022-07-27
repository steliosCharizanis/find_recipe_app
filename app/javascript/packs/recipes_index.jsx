import React, { Component } from 'react'
import ReactDOM from 'react-dom'
import MultipleValueTextInput from 'react-multivalue-text-input'

class App extends Component {
	constructor(props) {
		super(props);

		this.state = {
			items: [],
			searchResults: [],
			isChecked: false
		};

		this.handleChange = this.handleChange.bind(this);
		this.handleSubmit = this.handleSubmit.bind(this);
	}

	handleChange(event) {
		this.setState({ isChecked: !this.state.isChecked });
		if (this.state.items.length > 0)
			this.getSearchResults(this.state.items)
	}

	handleSubmit(event) {
		console.log(this.state);
		event.preventDefault();
	}

	getSearchResults(e) {
		console.log("items " + e)
		this.setState({
			items: e
		}, () => {
			fetch('/search?items=' + this.state.items + '&haveBasicIngredients=' + this.state.isChecked)
				.then(response => response.json())
				.then(data => this.setState({ searchResults: data.recipes }))
		});
	}

	render() {
		//console.log("search_results " + this.state.searchResults.count)
		//console.log("response " + response)
		let searchList = this.state.searchResults.map((response) => {
			return <div >
				<h2>{response.title}</h2>
				<p>total time {response.total_time}</p>
				<p>ratings {response.ratings}</p>
				<p>{response.missing_ingredients_text}</p>
				<p>{response.id}</p>
			</div>
		});

		return (
			<div>
				<h1>Recipes Search</h1>
				<p>Enter ingredients and find a recipe to cook</p>
				<MultipleValueTextInput
					onItemAdded={(item, allItems) => { this.state.items.push(item); this.getSearchResults(allItems) }}
					onItemDeleted={(item, allItems) => { this.state.items.pop(item); this.getSearchResults(allItems) }}
					label="Find A Recipe"
					name="item-input"
					charCodes={[32, 44, 13]}
					placeholder="Enter whatever items you want; separate them with COMMA or ENTER."
				/>
				<div>
					<label>
						<input type="checkbox" defaultChecked={this.state.isChecked} onChange={this.handleChange} />
						<span>I have basic ingredients (salt, pepper, water)</span>
					</label>
				</div>
				{searchList}
			</div>
		)
	}
}

document.addEventListener('DOMContentLoaded', () => {

	ReactDOM.render(
		<App />,
		document.body.appendChild(document.createElement('div'))
	)
})