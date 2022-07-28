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
			return <div className='col-md-4'>
				<div className="card">
					<img style={{ width: '100%', height: '100px' }} src={response.image} className="card-img-top" alt="Image" />
					<div className="card-body">
						<h5 className="card-title">{response.title}</h5>
						<p className="card-text">{response.missing_ingredients_text}</p>
						<p>ratings {response.ratings}</p>
						<p>eat in {response.total_time} minutes</p>
						<a className="btn btn-primary">Go to Recipe</a>
					</div>
				</div>
			</div>

		});

		return (
			<div className="container">
				<h1>Cook with what you have!</h1>
				<p>Enter ingredients and find a recipe to cook</p>
				<MultipleValueTextInput
					onItemAdded={(item, allItems) => { this.state.items.push(item); this.getSearchResults(allItems) }}
					onItemDeleted={(item, allItems) => { this.state.items.pop(item); this.getSearchResults(allItems) }}
					label="Ingredients"
					name="item-input"
					charCodes={[32, 44, 13]}
					placeholder="Enter whatever items you want; separate them with COMMA, ENTER or SPACE."
				/>
				<div>
					<label>
						<input type="checkbox" defaultChecked={this.state.isChecked} onChange={this.handleChange} />
						<span>  I have basic ingredients (salt, pepper, water)</span>
					</label>
				</div>
				<div className='row'>
					{searchList}
				</div>
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