import React, { Component } from 'react'
import ReactDOM from 'react-dom'
import MultipleValueTextInput from 'react-multivalue-text-input'

class App extends Component {
	constructor(props) {
		super(props);

		this.state = {
			items: [],
			searchResults: [],
			isChecked: false,
			isLoading: false,
			sortBy: 'highest_rated'
		};

		this.handleChange = this.handleChange.bind(this);
		this.handleSubmit = this.handleSubmit.bind(this);
		this.handleSortChange = this.handleSortChange.bind(this);
	}

	handleChange(event) {
		this.setState({ isChecked: !this.state.isChecked });
		if (this.state.items.length > 0)
			this.getSearchResults(this.state.items)
	}

	handleSortChange(sortBy) {
		this.setState({ sortBy }, () => {
			if (this.state.items.length > 0) {
				this.getSearchResults(this.state.items);
			}
		});
	}

	handleSubmit(event) {
		console.log(this.state);
		event.preventDefault();
	}

	getSearchResults(e) {
		console.log("items " + e)
		this.setState({
			items: e,
			isLoading: true
		}, () => {
			fetch('/search?items=' + this.state.items + '&haveBasicIngredients=' + this.state.isChecked + '&sortBy=' + this.state.sortBy)
				.then(response => response.json())
				.then(data => this.setState({ searchResults: data.recipes, isLoading: false }))
				.catch(error => {
					console.error('Error fetching recipes:', error);
					this.setState({ isLoading: false });
				});
		});
	}

	renderMissingBadge(missingCount) {
		let badgeClass = '';
		let badgeText = '';

		if (missingCount === 0) {
			badgeClass = 'badge bg-success';
			badgeText = '✓ Can make now!';
		} else if (missingCount === 1) {
			badgeClass = 'badge bg-warning text-dark';
			badgeText = `Missing ${missingCount} ingredient`;
		} else if (missingCount <= 3) {
			badgeClass = 'badge bg-warning text-dark';
			badgeText = `Missing ${missingCount} ingredients`;
		} else {
			badgeClass = 'badge bg-danger';
			badgeText = `Missing ${missingCount} ingredients`;
		}

		return (
			<div className="mb-2">
				<span className={badgeClass}>{badgeText}</span>
			</div>
		);
	}

	renderStars(rating) {
		const fullStars = Math.floor(rating);
		const decimalPart = rating % 1;
		const hasPartialStar = decimalPart > 0;
		const emptyStars = 5 - fullStars - (hasPartialStar ? 1 : 0);

		return (
			<span style={{ fontSize: '18px' }}>
				<span style={{ color: '#ffc107' }}>{'★'.repeat(fullStars)}</span>
				{hasPartialStar && (
					<span style={{
						position: 'relative',
						display: 'inline-block',
						width: '1em'
					}}>
						<span style={{ color: '#ddd' }}>★</span>
						<span style={{
							position: 'absolute',
							left: 0,
							top: 0,
							width: `${decimalPart * 100}%`,
							overflow: 'hidden',
							color: '#ffc107'
						}}>★</span>
					</span>
				)}
				<span style={{ color: '#ddd' }}>{'★'.repeat(emptyStars)}</span>
				<span style={{ color: '#6c757d', marginLeft: '5px', fontSize: '14px' }}>
					({rating})
				</span>
			</span>
		);
	}

	render() {
		//console.log("search_results " + this.state.searchResults.count)
		//console.log("response " + response)
		let searchList = this.state.searchResults.map((response) => {
			return <div className='col-md-3 mb-4'>
				<div className="card h-100" style={{ display: 'flex', flexDirection: 'column' }}>
					{response.image ? (
						<img
							style={{ width: '100%', height: '200px', objectFit: 'cover' }}
							src={response.image}
							className="card-img-top"
							alt={response.title}
							onError={(e) => {
								e.target.style.display = 'none';
								e.target.nextSibling.style.display = 'flex';
							}}
						/>
					) : null}
					<div style={{
						width: '100%',
						height: '200px',
						backgroundColor: '#e9ecef',
						display: response.image ? 'none' : 'flex',
						alignItems: 'center',
						justifyContent: 'center',
						color: '#6c757d',
						fontSize: '14px',
						fontWeight: '500'
					}}>
						No Image Available
					</div>
					<div className="card-body" style={{ display: 'flex', flexDirection: 'column', flex: 1 }}>
						<h5 className="card-title" style={{
							overflow: 'hidden',
							textOverflow: 'ellipsis',
							display: '-webkit-box',
							WebkitLineClamp: 2,
							WebkitBoxOrient: 'vertical',
							minHeight: '3em'
						}}>{response.title}</h5>
						{this.renderMissingBadge(response.missing_ingredients_count)}
						<div className="mb-2">{this.renderStars(response.ratings)}</div>
						<p>eat in {response.total_time} minutes</p>
						<div style={{ marginTop: 'auto' }}>
							<a className="btn btn-primary">Go to Recipe</a>
						</div>
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
					style={{ width: "100%" }}
				/>
				<div>
					<label>
						<input type="checkbox" defaultChecked={this.state.isChecked} onChange={this.handleChange} />
						<span>  I have basic ingredients (salt, pepper, water)</span>
					</label>
				</div>
				{this.state.items.length > 0 && (
					<div className="mt-3 mb-3">
						<small className="text-muted d-block mb-2">Sort results by:</small>
						<div className="btn-group" role="group" aria-label="Sort options">
							<button
								type="button"
								className={`btn ${this.state.sortBy === 'highest_rated' ? 'btn-primary' : 'btn-outline-primary'}`}
								onClick={() => this.handleSortChange('highest_rated')}
							>
								⭐ Highest Rated
							</button>
							<button
								type="button"
								className={`btn ${this.state.sortBy === 'quickest' ? 'btn-primary' : 'btn-outline-primary'}`}
								onClick={() => this.handleSortChange('quickest')}
							>
								⏱️ Quickest
							</button>
						</div>
					</div>
				)}
				{this.state.isLoading && (
					<div className="text-center my-5">
						<div className="spinner-border text-primary" role="status">
							<span className="visually-hidden">Loading...</span>
						</div>
						<p className="mt-2">Searching for recipes...</p>
					</div>
				)}
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