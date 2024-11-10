<script lang="ts">
    const validClass = 'valid';
    const invalidClass = 'invalid';

    let gridSize: number = 5;
    let maxNumber: number = 8;
    let grid: number[][] = setupGrid(gridSize);
    let partialGrid = grid.map(row => row.map(cell => Math.random() < 0.25 ? cell : null));

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

    function getRowSum(rowIndex: number): number {
        return grid[rowIndex].reduce((acc, cell) => acc + cell, 0);
    }


    function getColumnSum(columnIndex: number): number {
        return grid.reduce((acc, row) => acc + row[columnIndex], 0);
    }

    function validateGridInput(event: Event) {
        let input = event.target as HTMLInputElement;
        let value = input.value;

        if (value === '') {
            input.classList.remove(validClass, invalidClass);
            return;
        }

        let parsedValue = parseInt(value);

        let rowIndex = parseInt(input.dataset.row as string);
        let columnIndex = parseInt(input.dataset.column as string);
        let expectedValue = grid[rowIndex][columnIndex];

        if (parsedValue === expectedValue) {
            input.classList.remove(invalidClass);
            input.classList.add(validClass);
        } else {
            input.classList.remove(validClass);
            input.classList.add(invalidClass);
        }
    }

</script>
<main>
    <h1>Number Sum</h1>
    <p>
        The following {gridSize}x{gridSize} grid is partially complete with whole numbers from 1 to {maxNumber}.
    </p>

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
                        <td><input type="number" data-row="{rowIndex}" data-column="{columnIndex}" min="1" class="gridInput" max="{maxNumber + 1}" on:change={validateGridInput} /></td>
                    {:else}
                        <td>{cell}</td>
                    {/if}
                {/each}
            </tr>
        {/each}
        </tbody>
    </table>
</main>

<style>

    :global(.valid) {
        border-color: green;
    }

    :global(.invalid) {
        border-color: red;
    }

    td {
        vertical-align: middle;
        text-align: center;
    }

    .sum {
        font-weight: bold;
        border-radius: 50%;
        border: 1px solid blue;
    }
</style>