<?php
declare(strict_types=1);
namespace App\Tests\Unit;

use App\Entity\Task;
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;

class TaskTest extends KernelTestCase
{
    public function getEntity(): Task
    {
        return (new Task())->setName('UnitTestTaskName');
    }

    public function testConstructNomicalCase(): void
    {
        $task = $this->getEntity();
        self::assertInstanceOf(Task::class, $task);
    }

    public function testEntityConstraintsIsValidName(): void
    {
        self::bootKernel();
        $container = static::getContainer();

        $task = $this->getEntity();

        $errors = $container->get('validator')->validate($task);

        $this->assertCount(0, $errors);
    }

    public function testEntityConstraintsInvalidName(): void
    {
        self::bootKernel();
        $container = static::getContainer();

        $task = $this->getEntity();
        $task->setName('');

        $errors = $container->get('validator')->validate($task);
        $this->assertCount(1, $errors);
    }
}