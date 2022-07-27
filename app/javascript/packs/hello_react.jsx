// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import MultipleValueTextInput from 'react-multivalue-text-input'

const App = props => (
  <MultipleValueTextInput
    onItemAdded={(item, allItems) => console.log(`Item added: ${item}`)}
    onItemDeleted={(item, allItems) => console.log(`Item removed: ${item}`)}
    label="Find A Recipe"
    name="item-input"
    charCodes={[32]}
    placeholder="Enter whatever items you want; separate them with COMMA or ENTER."
  />
)

App.defaultProps = {
  name: 'David'
}

App.propTypes = {
  name: PropTypes.string
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <App name="React" />,
    document.body.appendChild(document.createElement('div')),
  )
})
