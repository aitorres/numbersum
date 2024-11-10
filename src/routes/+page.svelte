<script lang="ts">
	// Class names to provide visual feedback on the input fields
	const validClass = 'valid';
	const invalidClass = 'invalid';

	// Game configuration
	let gridSize: number = 5;
	let maxNumber: number = 7;
	let shownNumberProportion: number = 0.5;

	// Setting up game state -- this is only done once per game
	let grid: number[][] = setupGrid(gridSize);
	let partialGrid: (number | null)[][] = setupPartialGrid();

	// Sets up the game grid with random numbers for a given size
	function setupGrid(size: number): number[][] {
		let grid: number[][] = [];
		for (let i = 0; i < size; i++) {
			let row: number[] = [];
			for (let j = 0; j < size; j++) {
				row.push(Math.floor(Math.random() * maxNumber) + 1);
			}
			grid.push(row);
		}
		return grid;
	}

	// Sets up the partial grid with a proportion of the numbers shown,
	// to be filled in by the player
	function setupPartialGrid(): (number | null)[][] {
		return grid.map((row) =>
			row.map((cell) => (Math.random() < shownNumberProportion ? cell : null))
		);
	}

	// Counts the amount of empty spaces in the partial grid
	function getEmptySpaces(): number {
		return partialGrid.reduce((acc, row) => acc + row.filter((cell) => cell === null).length, 0);
	}

	// Returns the sum of a row in the grid
	function getRowSum(rowIndex: number): number {
		return grid[rowIndex].reduce((acc, cell) => acc + cell, 0);
	}

	// Returns the sum of a column in the grid
	function getColumnSum(columnIndex: number): number {
		return grid.reduce((acc, row) => acc + row[columnIndex], 0);
	}

	// On input field change, validates the input and provides visual feedback
	function validateGridInput(event: Event) {
		let input = event.target as HTMLInputElement;
		let value = input.value;

		// If the input is empty, remove any visual feedback
		if (value === '') {
			input.classList.remove(validClass, invalidClass);
			return;
		}

		let rowIndex = parseInt(input.dataset.row as string);
		let columnIndex = parseInt(input.dataset.column as string);

		let parsedValue = parseInt(value);
		let expectedValue = grid[rowIndex][columnIndex];

		// Add visual feedback based on the input value and the expected value
		if (parsedValue === expectedValue) {
			input.classList.remove(invalidClass);
			input.classList.add(validClass);
		} else {
			input.classList.remove(validClass);
			input.classList.add(invalidClass);
		}
	}

	// Checks if the game is complete by checking if all input fields are filled
	// and have the correct values
	function isGameComplete(): boolean {
		// Sanity check: has the document been loaded?
		if (typeof document === 'undefined') {
			return false;
		}

		// Sanity check: are there any input fields?
		let inputs = document.querySelectorAll('.gridInput');
		if (inputs.length === 0) {
			return false;
		}

		// If any input field is empty or invalid, the game is not complete
		for (let input of inputs) {
			let inputValue = (input as HTMLInputElement).valueAsNumber;

			if (isNaN(inputValue) || input.classList.contains(invalidClass)) {
				return false;
			}
		}

		// Sanity check: if there are no empty / invalid fields AND the number of valid inputs
		// matches the number of empty spaces, the game is complete
		let validInputs = document.querySelectorAll('.gridInput.valid').length;
		return getEmptySpaces() === validInputs;
	}

	// Language handling
	type Language = 'en' | 'es';

	// Attempt to get language from GET, default to English
	let language: Language = 'en';
	if (typeof window !== 'undefined') {
		let urlParams = new URLSearchParams(window.location.search);
		let urlLangParam: string | null = urlParams.get('lang');
		if (urlLangParam !== null && ['en', 'es'].includes(urlLangParam)) {
			language = urlParams.get('lang') as Language;
		}
	}

	// Strings per language
	const translatedStrings = {
		en: {
			explanationGridOfSize: 'The following grid of size',
			explanationPartiallyComplete: 'is partially complete with whole numbers from 1 to',
			explanationSumShown: 'The sum of each row and column is shown on the edges of the grid.',
			explanationFillIn: 'Fill in the missing numbers to complete the grid.',
			changeLanguage: 'En Español',
			congratulationsCompleted: 'Congratulations! You have completed the grid.',
			restartGame: 'Restart game',
			footerMadeWith: 'Made with',
			footerBy: 'by'
		},
		es: {
			explanationGridOfSize: 'El siguiente tablero de tamaño',
			explanationPartiallyComplete: 'está parcialmente completado con números enteros del 1 al',
			explanationSumShown: 'La suma de cada fila y columna se muestra en los bordes del tablero.',
			explanationFillIn: 'Rellena los números faltantes para completar el tablero.',
			changeLanguage: 'In English',
			congratulationsCompleted: '¡Felicidades! Has completado el tablero.',
			restartGame: 'Reiniciar juego',
			footerMadeWith: 'Hecho con',
			footerBy: 'por'
		}
	};
	const localization = translatedStrings[language];

	function changeLanguage() {
		let newLang = language === 'es' ? 'en' : 'es';
		let url = new URL(window.location.href);
		url.searchParams.set('lang', newLang);
		window.location.href = url.toString();
	}
</script>

<main>
	<h1>Number Sum</h1>
	<div class="explanation">
		<p>
			{localization['explanationGridOfSize']}
			{gridSize}x{gridSize}
			{localization['explanationPartiallyComplete']}
			{maxNumber}.
		</p>
		<p>{localization['explanationSumShown']}</p>
		<p>{localization['explanationFillIn']}</p>
		<button on:click={changeLanguage}>{localization['changeLanguage']}</button>
	</div>

	<table class="grid">
		<tbody>
			<tr>
				<td></td>
				{#each grid as _, columnIndex}
					<td class="sum">{getColumnSum(columnIndex)}</td>
				{/each}
			</tr>
			{#each partialGrid as row, rowIndex}
				<tr>
					<td class="sum">{getRowSum(rowIndex)}</td>
					{#each row as cell, columnIndex}
						{#if cell === null}
							<td
								><input
									type="number"
									data-row={rowIndex}
									data-column={columnIndex}
									min="1"
									class="gridInput"
									max={maxNumber + 1}
									on:change={validateGridInput}
								/></td
							>
						{:else}
							<td>{cell}</td>
						{/if}
					{/each}
				</tr>
			{/each}
		</tbody>
	</table>

	{#if isGameComplete()}
		<p>{localization['congratulationsCompleted']}</p>
	{/if}
	<button on:click={() => location.reload()}>{localization['restartGame']}</button>

	<footer>
		{localization['footerMadeWith']} <span class="heart">♥</span>
		{localization['footerBy']}
		<a href="https://aitorres.com" title="Andrés Ignacio Torres">Andrés Ignacio Torres</a>
	</footer>
</main>

<style>
	main {
		font-family: 'Helvetica', 'Verdana', sans-serif;
		min-width: 320px;
		width: 60vw;
		margin: 4em auto;
	}

	h1,
	p,
	footer {
		text-align: center;
	}

	table,
	button {
		margin: 0 auto;
	}

	button {
		display: block;
		background-color: #bacaf5;
		border-radius: 20px;
		border: 1px solid black;
		padding: 0.5em 1em;
		box-shadow: 2px 2px 2px rgba(0, 0, 0, 0.2);
	}

	button:active {
		box-shadow: none;
	}

	.explanation,
	table,
	footer {
		margin-top: 3em;
		margin-bottom: 3em;
	}

	:global(.valid) {
		border-color: rgb(153, 238, 153);
	}

	:global(.invalid) {
		border-color: red;
	}

	.heart {
		color: red;
		font-weight: bold;
	}

	td {
		vertical-align: middle;
		text-align: center;

		width: 30px;
		height: 30px;
	}

	.sum {
		font-weight: bold;
		border-radius: 50%;
		border: 1px solid blue;
	}
</style>
